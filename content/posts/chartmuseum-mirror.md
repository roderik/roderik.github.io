+++
title = "Chartmuseum Mirror"
date = "2021-02-24T17:57:35+01:00"
author = "Roderik van der Veer"
authorTwitter = "r0derik" #do not include @
cover = ""
tags = ["devops", "helm","chartmuseum"]
keywords = ["", ""]
description = "Since the stable and incubation helm chart repositories are deprecated, charts are published in a multitude of locations. Unfortunately not all these locations are as stable. In this post we will setup Chartmuseum on a Kubernetes cluster, backed by AWS S3 and use it and Github Actions to publish our own charts and mirror the repositoreis we need."
showFullContent = false
+++

Since the stable and incubation helm chart repositories are deprecated, charts are published in a multitude of locations. Unfortunately not all these locations are as stable as you would expect them to be. In this post we will setup Chartmuseum on a Kubernetes cluster, backed by AWS S3 and use it and Github Actions to publish our own charts and mirror the repositoreis we need.

## Using Pulumi to bootstrap our infrastructure

[Pulumi](https://www.pulumi.com) is a tool that allows us to leverage familiar programming languages to define our infrastructure as code. In this post we will be using the Typescript version of Pulumi together with a free account.

Let's install Pulumi using [Homebrew](https://brew.sh) since I use MacOS. You can use Pulumi on any operating system and [the installation instructions can be found in the documentation](https://www.pulumi.com/docs/get-started/install/). FYI, a lot of the Pulumi code samples is copied from the Pulumi documentation, the go-to source for anything you want to do with Pulumi.

```sh
brew install pulumi
```

You will also need a free account from the [Pulumi website](https://www.pulumi.com). This account is used to store the state of your infrastructure. You can also use your own backend if you do not feel comfortable using the Pulumi backend, the configuration of this can be found in [the docs](https://www.pulumi.com/docs/guides/self-hosted/).

Using this account, you can log in on your computer

```shell
pulumi login
```

In your account settings, under Access Tokens, you need to create a new token. Save the token for the future steps. It looks like this (obviously this is not my token 🤦):

```text
pul-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

This handled, we will create the Pulumi stack for this tutorial.

```shell
mkdir chartmuseum-tutorial && cd chartmuseum-tutorial
pulumi new aws-typescript
```

The Pulumi CLI will ask you some questions to complete the setup

- Enter in a Pulumi project name, and description to detail what this Pulumi program does
- Enter in a name for the Pulumi stack, which is an instance of our Pulumi program, and is used to distinguish amongst different development phases and environments of your work streams.
- Your preferred AWS zone

## Setting up the Kubernetes Cluster on EKS

Let's start off by creating the cluster. First we need to add some more dependencies.

```shell
npm install --save @pulumi/eks @pulumi/kubernetes
```

Open the existing file index.ts, and replace the contents with the following:

```typescript
import * as pulumi from "@pulumi/pulumi";
import * as awsx from "@pulumi/awsx";
import * as eks from "@pulumi/eks";
import * as k8s from "@pulumi/kubernetes";

const name = "chartmuseum";

// Create an EKS cluster with non-default configuration
const vpc = new awsx.ec2.Vpc("vpc", { subnets: [{ type: "public" }] });
const cluster = new eks.Cluster(name, {
    vpcId: vpc.id,
    subnetIds: vpc.publicSubnetIds,
    desiredCapacity: 2,
    minSize: 1,
    maxSize: 2,
    storageClasses: "gp2",
    deployDashboard: false,
});

// Export the clusters' kubeconfig.
export const kubeconfig = cluster.kubeconfig
```

The index.ts occupies the role as the main entrypoint in our Pulumi program. In it, we are going to declare:

- The resources we want in AWS to provision the EKS cluster based on our cluster configuration settings,
- The kubeconfig file to access the cluster, and
- The initialization of a Pulumi Kubernetes provider with the kubeconfig, so that we can deploy Kubernetes resources to the cluster once its ready in the next steps.

You will notice that there is hardly any configuration needed. But this does not mean you cannot tune everything to your harts content. Since we use typescrupt, you can easily find all configuration settings in the type definitions of the `ClusterOptions` argument.

Before we can deploy this cluster, we still need to configure our AWS credentials, there are many options, choose your poison [in the AWS provider documentation](https://www.pulumi.com/docs/intro/cloud-providers/aws/#configuration).

```shell
pulumi config set aws:accessKey AAAAAAAAAAAAAAAAAAAA --secret
pulumi config set aws:secretKey m/ZTX/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --secret
```

By using --secret, the value is encrypted and you can commit it to git. It stores these configuration values in the Pulumi.stackname.yaml file.

We can not deploy the cluster by running

```shell
pulumi up
```

{{< image src="/images/2021/chartmuseum-mirror/clustercreation.gif" alt="Cluster creation with pulumi up" position="center" style="border-radius: 8px;" >}}

## Deploying ChartMuseum on our cluster

Since we are going to need a domainname pointed tot he chartmuseum instance, we will add a [Cloudflare](https://cloudflare.com) dependency so we can use it to create and manage the domainname. Pulumi supports a lot of DNS providers, as stated before, check the docs for other setups.

```shell
npm install --save @pulumi/cloudflare
```

In this case, I'll assume your domainname is already configured in Cloudflare. We will first need your domainnames Zone ID which we will set in the config.

```shell
pulumi config set zoneId xxxxxxxxxxxxxxxxxxxxx --secret
pulumi config set cloudflare:email roderik@vanderveer.be
pulumi config set cloudflare:apiKey xxxxxxxxxxxxxxxxxxxxx --secret
```

Notice that I set the Zone Id as a secret, while it is not secret, I do not want to expose it in the public GIT repo for this post.

We will start adding a namespace, ingress controller and link the domainname to it. At the bottom of the index.ts file, add the following.

```typescript
// Create a k8s provider
const provider = new k8s.Provider('k8s', { kubeconfig });

// Setup a namespace

new k8s.core.v1.Namespace(
  `${name}-namespace`,
  { metadata: { name } },
  { provider }
);

// Deploy an ingress controller into it

const nginxIngress = new k8s.helm.v3.Chart(
  `${name}-ingress`,
  {
    chart: 'ingress-nginx',
    version: '3.15.2',
    fetchOpts: {
      repo: 'https://kubernetes.github.io/ingress-nginx',
    },
    namespace: name,
    values: {
      controller: {
        scope: {
          enabled: true,
        },
        replicaCount: 2,
        metrics: {
          enabled: true,
        },
        admissionWebhooks: {
          enabled: false,
        },
      },
    },
  },
  {
    provider,
    ignoreChanges: ['status', 'metadata'],
  }
);

// Fetch the ingress URL from the service

const controllerService = nginxIngress.getResource(
  'v1/Service',
  name,
  `${name}-ingress-ingress-nginx-controller`
);

const ingressUrl = controllerService.status.apply(
  (status) => status.loadBalancer.ingress[0].hostname
);

// Get access to the config
const config = new pulumi.Config();
const awsConfig = new pulumi.Config('aws');

// Create a domainname for this ingress using Cloudflare
new cloudflare.Record(`${name}-dns`, {
  name: `charts`,
  zoneId: config.requireSecret('zoneId'),
  type: 'A',
  value: ingressUrl,
  proxied: true,
});
```

This will

- create a k8s provider, this provider is similar to setting up your kubeconfig on your computer to execute commands on the cluster;
- setup a namespace to deploy all the resources in;
- deploy the ingress-nginx ingress controller into that namespace from the official helm chart repository;
- when it it deployed, we will fetch the ingress URL from the service, on AWS you get a hostname, on EKS/AKS an IP address;
- and finally we create an CNAME record in Cloudflare for charts.vanderveer.be to the hostname of our ingress ELB.

Now we will update our infrastructure by running `pulumi up` again.

{{< image src="/images/2021/chartmuseum-mirror/dns.gif" alt="Deploying the ingress and domainname" position="center" style="border-radius: 8px;" >}}

## Creating your own charts

## Publish your charts to ChartMuseum via Github Actions

## Mirroring other chart repositories

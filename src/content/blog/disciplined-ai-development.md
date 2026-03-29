---
title: 'AI Exposes the Discipline You Already Had (or Didn''t)'
description: 'After eighteen months of running AI agents on production code at SettleMint, the pattern is clear: the teams struggling aren''t failing because of the AI. The AI is just making their existing problems faster.'
pubDate: 2026-01-20
tags: ['ai', 'engineering', 'leadership', 'agents']
---

A few weeks ago, a silent failure hunter — an agent I run specifically to look for error handling gaps — caught something that our normal review process had completely missed. An API integration with no timeout handling. The implementing agent had marked it done, tests passed, the spec reviewer signed off. But when the silent failure hunter asked "what happens if this service never responds?", the answer was: nothing. The request queue would hang indefinitely, waiting for a response that might not come.

The fix was three lines. The bug would have been very hard to diagnose in production.

I've been thinking about why that bug made it through everything else.

## The pattern I kept seeing

Eighteen months ago I started running AI coding agents on real production work at SettleMint — not demos, not toy projects, actual features shipping to customers. The first few months were educational in a humbling way.

The agents were capable. Better than I expected, honestly. But the output had a consistent character: it handled the happy path beautifully and silently failed on every boundary condition. Timeouts. Missing error handlers. Race conditions. Unchecked promises. The code *looked* right. It passed review. It passed tests. And then it would fall apart in ways that were annoying to debug because there was no error message, just nothing happening.

At first I thought this was an AI problem. Train better models, get better code.

Then I started noticing the same pattern in code written by humans on the team. We had always had silent failures in our codebase. The AI wasn't introducing a new failure mode. It was producing our existing failure modes at higher velocity.

That was the uncomfortable realization: the AI was writing code that looked like our codebase. Which meant it was also inheriting our codebase's habits, including the bad ones.

## Tests as a specification problem

The standard advice is "write tests." But the reason tests matter for AI-generated code is slightly different from why they matter in general.

When a human writes code, they have some mental model of the system. They might not write it down, but they're reasoning about edge cases even if they don't test them. The code often works in untested scenarios because the author was thinking about the system while writing it.

AI doesn't have that. It generates statistically plausible code based on patterns in training data. It doesn't know your system. It doesn't know your business domain. When you ask it to "add authentication," it will produce authentication code that looks like authentication code — and that's all it can do. It won't know that your session tokens work differently from the standard pattern, or that you have a specific timeout requirement from a compliance rule it's never seen.

Tests are the only way to give the AI a concrete specification. With a failing test, the AI has something to converge toward. Without tests, it's producing code that matches patterns in its training data, and you're hoping those patterns happen to match your requirements.

The part that took me too long to internalize: the test isn't just a check, it's the spec. Writing the test first forces you to articulate exactly what "correct" means before asking the AI to produce it.

## Two things I changed

**Separate contexts for each task.** Early on I was running long sessions where an AI would implement one feature, then another, then a third in the same conversation. By the third feature, the output quality had degraded noticeably. The agent would make decisions that contradicted earlier work, or apply patterns from the second task to the third where they didn't belong. I started giving each task a fresh context. The overhead is annoying but the quality difference is real.

**Separate review agents, separate questions.** I used to run one review pass: "does this look good?" That's too vague. I now run at least two: one agent checks whether the implementation matches the spec, a second checks the implementation quality independently. They don't see each other's output. Separating "does it work" from "is it good" makes both reviews sharper.

The silent failure hunter is a third pass with a specific mandate: ignore whether the code works correctly, just look for paths where failures would be swallowed. Unchecked promises. Missing timeouts. Error handlers that catch and do nothing. That API timeout bug? The first two reviews weren't looking for it. The silent failure hunter was.

## What I actually verify

There's a habit I had to break: trusting agent-reported status. The AI says "tests pass" — did they actually pass? The AI says "linting is clean" — is it? I caught enough cases of agents confidently reporting success while tests were failing (usually because they'd made a change that should have fixed the issue and assumed it had) that I now have a mechanical rule: I don't accept a completion claim without seeing the actual output.

It sounds paranoid. It's caught real bugs often enough that I still do it.

The pattern I use: identify the command that would prove the claim, run it fresh, read the full output. Not "I believe the tests pass" but "I ran `npm test` and here's the output showing green."

## The part I didn't expect

Adding structure to AI development made it faster, not slower.

The naive model says: more process = more friction = slower. And it's true that writing tests and running multiple review passes takes time. But the time you spend on that is paid once. The time you spend debugging a silent failure in production — figuring out *why* nothing is happening, where the hang is, what the original intent was — that gets paid over and over.

In the early months, before I'd figured out the review structure, I was spending roughly 60% of time fixing AI-generated issues. The net was negative: I would have shipped faster by just writing the code. After the structure was in place, that dropped to maybe 15%, and the code that went to production was substantially more reliable.

The AI is still the same AI. The difference is what it's asked to do.

## Why the silent failure hunter matters

The bug I opened with — the API timeout — is a good example of why generic code review doesn't catch this class of problem. The code was correct in every sense the reviewers were checking. It called the right endpoint, parsed the response correctly, handled error status codes. The reviewer confirming spec compliance found nothing wrong. The quality reviewer found nothing wrong.

The silent failure hunter found the gap because that's the only question it's asking. It doesn't care if the code is correct. It wants to know: what happens when things go wrong? Where are the paths where a failure would be invisible?

That's a different question than "is this good code," and it needs to be asked separately.

---

*The workflow I run — plan mode, build mode, reviewer agents, silent failure hunter — is at [github.com/settlemint/agent-marketplace](https://github.com/settlemint/agent-marketplace).*

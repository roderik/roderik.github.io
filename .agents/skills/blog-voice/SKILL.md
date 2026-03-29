# Blog Voice

Write technical blog posts in the style of Andrej Karpathy — one of the clearest technical writers working today.

## When to Use

Invoke this skill whenever writing or editing a post for vanderveer.be. The goal is not imitation but internalization: write the way a senior engineer would if they cared about being genuinely useful to the reader.

## The Core Orientation

Karpathy writes like he's sharing something he actually figured out, not teaching a lesson he already knew. The reader gets to watch him think. That's the thing to replicate.

The posture is: **I found something interesting. Let me show you what I saw and why it matters.**

Not: here is a framework. Not: follow these five steps. Not: research shows.

## Voice

**First person, always.** "I" is the protagonist. "We" only when genuinely a team effort and the team matters to the story. Never the academic "one" or the corporate "the team."

**Observational, not prescriptive.** The writer notices things. The reader draws conclusions. You can share what you concluded, but you don't tell the reader what they should do.

> Good: "I stopped doing X and the codebase got easier to navigate."
> Bad: "You should stop doing X."

**Intellectually honest.** Acknowledge what you don't know. Say "I think" when you think, not when you know. Say "I'm not sure why" when you're not sure. This is not weakness — it's the thing that makes technical writing trustworthy.

> Good: "This probably works because of X, though I haven't verified that."
> Bad: "This works because of X."

**Casual but precise.** "kinda", "roughly", "basically", "at some point" are fine. Vague technical claims are not. The informality is in how you hold ideas, not in the ideas themselves.

**Dry humor is welcome.** Not jokes. Not wit for its own sake. But if something is genuinely funny about how you learned a thing, say so.

## Structure

**Open with something specific.** Not a thesis statement. A moment, an observation, a number, a thing that happened. The generalization can come later.

> Good: "I spent three days convinced the bug was in the tokenizer. It was not in the tokenizer."
> Bad: "Context window management is one of the most underappreciated challenges in LLM development."

**Let the structure emerge from the content.** Not every post needs headers. When you use headers, make them statements or specific observations, not topic labels.

> Good: "The tokenizer was fine"
> Bad: "Background" / "Problem" / "Solution"

**Short sentences land harder after long ones.** Vary the rhythm. A long explanatory paragraph followed by a two-word sentence does more than three medium sentences.

**Build intuition, not just information.** The reader should leave understanding *why*, not just *what*. If you can't explain why something works the way it does, say so — that's interesting too.

**End with reflection, not a bow.** Don't summarize. Don't list takeaways. Don't say "in conclusion." The post can just... end. Ideally with something that opens out — a question, an implication, a thing you're still thinking about.

## Anti-Patterns

These are the tells of AI-written or corporate blog posts. Avoid them.

**Rhetorical lead-ins:**
- "Here's the thing:" / "Here's what I found:" / "Here's the uncomfortable truth:"
- "What surprised me most was..."
- "The key insight is..."
- "The bottom line:"

These phrases announce an insight instead of delivering it. Just deliver it.

**Prescriptive imperatives:**
- "You should..." / "Teams need to..." / "The answer is to..."
- "The winning teams will be those who..."
- "This is [X] done right."

**Marketing language:**
- "10x productivity" / "force multiplier" / "game-changing"
- "In my experience..." as throat-clearing
- CTAs disguised as humility: "We've open-sourced..." at the end

**Clean narrative arcs.** Real technical work is messy. A post that goes problem → insight → clean solution → results feels written. Show the detour you took, the thing that didn't work, the thing you still don't understand.

**Numbered lists as a structure crutch.** Lists are fine for actual enumerations (steps, tools, config options). They're lazy when used to avoid writing real paragraphs about something you haven't fully thought through.

## On Length

Karpathy writes very long posts when the subject warrants it. Length is earned by having more to say, not by padding. A 500-word post that says one sharp thing clearly is better than a 2000-word post that says the same thing with scaffolding.

## On Technical Content

Code is a first-class citizen. When the code is the thing, show the code. Don't summarize what the code does when you can show the code.

Numbers and specifics make claims real. "About 60% of time went to debugging" > "most of the time went to debugging". Exact error messages, exact command outputs, exact version numbers — these signal that you actually did the thing.

Historical context matters. How did we end up here? Why does this work this way and not some other way? Understanding the path often explains the current state better than describing the current state directly.

## Workflow

When writing a new post:
1. Start with what you actually noticed/learned, not with what you want to convey
2. Write a rough draft without worrying about structure
3. Find the sharpest observation in the draft — that's probably the real opening
4. Cut everything that's scaffolding (throat-clearing, transitions that explain what you're about to do, summaries of what you just said)
5. Read it aloud. Anything that sounds like a corporate blog post, rewrite

When editing an existing AI-written post:
1. Identify the 2-3 things the post actually has to say
2. Find the most specific/concrete moment in the post — that's probably the real opening
3. Rewrite section by section, replacing rhetorical lead-ins with direct statements
4. Remove the prescriptive ending; find a more honest note to close on
5. Add specific numbers and details where the post is currently vague

## Reference

The clearest examples of the target voice: Karpathy's "The Unreasonable Effectiveness of Recurrent Neural Networks" (long-form, builds intuition), "Software 2.0" (concise, reframes a familiar thing), "Recipe for Training Neural Networks" (practical, honest about what goes wrong), and "A Hackers Guide to Language Models" (accessible depth without condescension).

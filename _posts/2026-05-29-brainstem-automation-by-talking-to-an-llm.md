---
title: 'Editing BrainSTEM by Talking to an LLM'
tags: [Computer, Lab]
status: publish
type: post
published: true

toc: true
toc_label: "outline"
toc_icon: "guitar"
comments: false
header:
  overlay_image: /assets/images/blog/brainstem.png
  overlay_filter: rgba(0,0,0,0.8)
  teaser: /assets/images/blog/brainstem.png
classes:
  - wide

permalink: /blog/:year/:month/:day/:title

excerpt: I built a Python workflow that lets me update BrainSTEM records by talking to an LLM instead of clicking through the browser one record at a time.
---

The main thing I wanted out of this project was not just automation.
I wanted a different workflow.

Instead of opening [BrainSTEM] in the browser and editing records one by one, I can now describe what I want in natural language and let the automation layer turn that request into actual BrainSTEM edits.

That is the central idea of this post.

The code is here: [brainstem-automation](https://github.com/yfujis/brainstem-automation)

## Why I wanted this

[BrainSTEM] is a very useful system for logging experimental data. It is specifically designed for neuroscience research and keeps improving based on feedback from users. But repetitive edits in the browser are still slow. At one point I needed to update a group of animals by hand, and that made the friction obvious.

I wanted to be able to say things like:

1. create a procedure log
2. update notes across multiple subjects
3. normalize fields so they are consistent
4. verify the result after writing

without manually repeating the same browser actions every time.

## What changed

The biggest change is that I can now talk to an LLM and express the intent directly.
The automation code then handles the structured BrainSTEM request for me.

That means the workflow changed from:

1. open record
2. scroll to the right field
3. edit one value
4. save
5. repeat

into something closer to:

1. describe the change in plain language
2. let the tool map that request to BrainSTEM fields
3. check the result programmatically

That sounds small, but in practice it is a major shift in how the work feels.

I have already used this workflow with an LLM on a real batch update. For example, my prompt looked like this:

```text
Please make sure that all subjects below have viral injection logs with two depths and optic-fiber implant logs. Remove details like body weight, since each animal had a different value.

subject | virus (from our lab AAV inventory) | date of virus injection | date of optic fiber

Animal A | Virus A | March 11, 2024 | April 6, 2024
Animal B | Virus A | March 18, 2024 | May 3, 2024
Animal C | Virus A and Virus B | April 3, 2024 | June 27, 2024
Animal D | Virus A and Virus B | April 4, 2024 | June 1, 2024
Animal E | Virus A and Virus B | April 13, 2024 | June 10, 2024
Animal F | Virus A and Virus B | May 11, 2024 | July 14, 2024
Animal G | Virus A and Virus B | June 20, 2024 | August 5, 2024
Animal H | Virus A and Virus B | June 20, 2024 | July 29, 2024
Animal I | Virus A and Virus B | July 3, 2024 | September 24, 2024
```

After that, I made a few corrections by prompting:

```text
Actually, Animal E and Animal G had both the virus and fiber on the right hemisphere. Please update those records accordingly.
```

The LLM handled both updates cleanly.


## What I built

I made a small standalone Python repository around the official BrainSTEM API tooling.

The repository contains:

1. a lightweight client wrapper
2. CLI commands for listing, creating, and updating records
3. setup instructions for authentication and usage
4. packaging metadata so it can be reused cleanly

The repo is intentionally simple.
I wanted something I could understand, inspect, and rerun later without a lot of friction.

## Why this matters to me

The main benefits have been:

1. speed
2. consistency
3. lower cognitive load

It also makes batch updates much more practical.
If I need to normalize notes or correct metadata across many subjects, I can do that with a script instead of a long browser session.

## Try it yourself

If you want to see the workflow or adapt it for your own setup, you can start here:

[https://github.com/yfujis/brainstem-automation](https://github.com/yfujis/brainstem-automation)

The basic idea is:

1. clone the repo
2. install the dependencies
3. authenticate with BrainSTEM
4. start with a small test update
5. expand to larger edits once the flow is confirmed

## A note on safety

When using this repository for your own work, it's good to keep in mind that you should not include:

1. hardcoded tokens
2. personal local file paths
3. identifying examples that should stay private

The token is handled through an environment variable, and sensitive values should stay out of git.

[BrainStem]: https://www.brainstem.org/
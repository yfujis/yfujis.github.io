---
title: "Keeping a Lab Notebook by Talking to an LLM"
tags: [Computer]
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

## Motivation

It is essential for experimental researchers to maintain accurate and up-to-date records of their work. [BrainSTEM] is a particularly useful system because it is designed specifically for neuroscience research, especially in vivo physiology. The team led by [Peter Petersen](https://petersenlab.org/) continues to improve the platform based on feedback from the neuroscience community.

One aspect that can become cumbersome, however, is performing batch updates. While the web interface works well for individual edits, updating many records often requires clicking through multiple pages and modifying entries one at a time. Since BrainSTEM provides a well-designed Python API, I thought it would be interesting to build a workflow that allows me to express update requests in natural language through an LLM, while the underlying automation translates those requests into structured BrainSTEM API calls. This approach makes batch updates faster, reduces repetitive manual work, and lowers the cognitive overhead of maintaining records.

## What I built

I made a small standalone Python [repository](https://github.com/yfujis/brainstem-automation) around the official BrainSTEM API tooling.

The repository contains:

1. A lightweight client wrapper
2. CLI commands for listing, creating, and updating records
3. Setup instructions for authentication and usage
4. Packaging metadata so it can be reused cleanly

## New workflow

The biggest change is that I can now talk to an LLM and express the intent directly.
The automation code then handles the structured BrainSTEM request for me.

That means the workflow changed from:

1. open record
2. scroll to the right field
3. edit one value
4. save
5. repeat

into something closer to:

1. Describe the change in plain language
2. Let the tool map that request to BrainSTEM fields
3. Check the result and accept or make further adjustments

An example of a batch update I tried looks something like this:

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

The LLM handled this very nicely.

## Try it yourself

If you want to see the workflow or adapt it for your own setup, you can start [here](https://github.com/yfujis/brainstem-automation). You do not have to use this repo specifically, since you could probably write (vibe-code) something similar yourself.

The basic steps are:

1. Clone the repo
2. Install the dependencies
3. Authenticate with BrainSTEM
4. Start with a small test update
5. Expand to larger edits once the flow is confirmed

I hope this can be a useful tool for other BrainSTEM users, and also a fun example of how LLMs can be used to automate scientific workflows in a more natural way.

[BrainStem]: https://www.brainstem.org/

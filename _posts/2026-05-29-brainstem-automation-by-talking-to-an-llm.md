---
title: 'Keeping a Lab Notebook by Talking to an LLM'
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

It is essential for experimental researchers to keep accurate and up-to-date records of their work. [BrainSTEM] is a very useful system because it is specifically designed for neuroscience research. The team led by [Peter Petersen](https://petersenlab.org/) keeps improving it based on user feedback. When you want a batch update, it can be a bit of a pain to click through the browser and edit each record one at a time. Since they have a nice Python API, I thought it would be fun to build a workflow that lets me talk to an LLM and express the intent directly, and then the automation code handles the structured BrainSTEM request for me. This way, I can make batch updates much faster and with less cognitive load.

## What I built

I made a small standalone Python [repository](https://github.com/yfujis/brainstem-automation) around the official BrainSTEM API tooling.

The repository contains:

1. a lightweight client wrapper
2. CLI commands for listing, creating, and updating records
3. setup instructions for authentication and usage
4. packaging metadata so it can be reused cleanly


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

1. describe the change in plain language
2. let the tool map that request to BrainSTEM fields
3. check the result and accept or make further adjustments

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

If you want to see the workflow or adapt it for your own setup, you can start [here](https://github.com/yfujis/brainstem-automation). You do not have to use this repo, since you could probably write something similar yourself.

The basic steps to get started are:

1. clone the repo
2. install the dependencies
3. authenticate with BrainSTEM
4. start with a small test update
5. expand to larger edits once the flow is confirmed

I hope this can be a useful tool for other BrainSTEM users, and also a fun example of how LLMs can be used to automate scientific workflows in a more natural way.

[BrainStem]: https://www.brainstem.org/
---
title: 'Getting started with Neovim on Ubuntu'
tags: [Computer]
status: writing

toc: true
toc_label: "outline"
toc_icon: "guitar"
comments: true

permalink: /blog/:year/:month/:day/:title
--- 
I've recently had a chance to use a computer with Ubuntu for my reserch. So, I'd like to write the needed steps as a memorandum.

OS: Ubuntu 20.04.2 LTS

# Installation
To install neovim, write:
```bash
sudo apt install neovim
```
You might have to upgrade apt:
```bash
sudo apt upgrade
sudo apt upgrade
```
## Custimize your neovim interface
By creating and editting init.vim, you can custimize your neovim to look and work however you want it to. For example, you can change the background and letter colors. init.vim is executed every time you start neovim. So by listing the plugsins you want to work with here, your setup will always be ready.



---
title: 'multitapers'
tags: [Math, Computer]
status: writing

toc: true
toc_label: "outline"
toc_icon: "guitar"
comments: true

permalink: /blog/:year/:month/:day/:title
--- 

There are a number of methods available perform time-frequency analysis: short-time FFT (fast Fourier transformation), wavelet convolutions, and multitapers, just to name a few. Each method has its advantages and disadvantages, one thus chooses a method depending on the characteristics of their dataset and their research questions. In this post, I would like to describe the motivation to use multitapers as to look at dynamical changes of signals in frequency domain.

## How does the multitapering method work?
One could argue that the multitaper method is an extension of the short-time FFT method.

If you know the short-time FFT (or just FFT) method, you know that a taper is multiplied element-wise to segmented time series. mitigate the contamination caused by the edge artifacts. By chopping the time domain signal into segments, multiplying the segment with a taper element-wise, and performing discrete FFT on the tapered signal, short-time FFT allows one to observe the power spectral density over time.

$$
x = y
$$


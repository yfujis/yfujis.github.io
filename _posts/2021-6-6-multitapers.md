---
title: 'Multitapers (in progress)'
tags: [Math, Signal Processing, Data Science]
status: partially published

toc: true
toc_label: "outline"
toc_icon: "guitar"
comments: true

permalink: /blog/:year/:month/:day/:title
--- 

There are a number of methods available to perform a time-frequency analysis: short-time FFT (fast Fourier transformation), wavelet convolutions, and multitapers, just to name a few. Each method has its advantages and disadvantages, one thus chooses a method depending on the characteristics of their dataset and their research questions. In this post, I would like to describe the motivation to use multitapers to look at dynamical changes of signals in the frequency domain.

# Similar to the short-time FFT?
One can say that the multitaper method is an extension of the short-time FFT method. The short-time FFT chops the entire trial period into segments and performs discrete Fourier transform (DFT) on each of them, which allows us to estimate the power spectrum over time. The multitaper method adopts the same strategy of extracting time segments to observe temporal changes in the frequency domain.

# How is it different from the short-time FFT?
Before performing DFT on a time segment, the short-time FFT oftens applies a taper to the time segment to mitigate the edge artifacts.



*****
If you know the short-time FFT method, you know that a taper can be multiplied element-wise to segmented time series, which mitigates the contamination caused by the edge artifacts. By chopping the time domain signal into segments, multiplying the segment with a taper element-wise, and performing discrete FFT on the tapered signal, you observe the power spectral density over time.

The basic idea of the multitaper method is the same as the short-time FFT, but it is meant to improve the signal-to-noise ratio by applying (literally) multiple tapers. The power spectrum of a given frequency is estimated by averaging over results of DFT on segments multiplied by different tapers. The tapers used in this method are called discrete prolate spheroidal sequences a.k.a. Slepian tapers and they are orthogonal to each other, which means the tapered time series with each taper has a focus on different frequency ranges.

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
Before performing DFT on a time segment, the short-time FFT often applies a taper to the time segment to mitigate the edge artifacts. The multitaper method on the other hand as the name indicates applies multiple tapers, which results in multiple tapered time series. Subsequently, the DFT is performed on tapered segments, and the obtained power spectra are averaged over time series with different tapers applied. The resulting power spectra by the multitaper method is an average of multiple spectra, it is in principle smoother than the power spectra the short-time FFT produces.

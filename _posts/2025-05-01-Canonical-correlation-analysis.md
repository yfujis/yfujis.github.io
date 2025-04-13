## Motivations
With the advent of technologies, we as neuroscientists now have the exciting opportunities to probe the brain by recording the activity of tens, hundreds, sometimes even thousands of neurons simultaneously. Beyond just neural recordings, we are increasingly able to quantify behavior in rich and complex ways—ranging from motion tracking to acoustic profiling and many others.

Many of us, systems neuroscientists, including myself are strongly interested in understanding how the brain generates/controls a behavior. And, this is probably the most exciting time to be in the field of neuroscience. (And, it will probably keep getting more and more exciting.)

However, with great data comes great responsibility. One major challenge we face is making sense of the enormous high-dimensional datasets, namely finding meaningful relationships between brain activity and behavior when both exist in complex, high-dimensional spaces? To this end, many researchers, especially those who are savvy in quantitative fields such as applied mathematics, statistics, and physics created/translated/transferred analytical frameworks that are useful in answering questions that neuroscientists have. Canonical correlation analysis (CCA) is one such example that I picked as a topic to write a blogpost on, after seeing it used in some papers revealing some cools insights.

## Refreshing on matrix factorization
*Skip this section if you are already comfortable with PCA, especially if you have good intuitions about implications of running PCA on a data matrix and its transpose.*

### What is Matrix Factorization?
General understanding of **matrix factorization** will be useful for understanding how CCA works and the interpretation. I will briefly touch on this with principal component analysis (PCA) as am example.

Matrix factorization is a general technique in linear algebra where a given matrix is decomposed (or 'factored') into a product of two or more matrices. The idea is to represent (or approximate) the original data in a way that is useful to us (e.g. reveals hidden structure, reduces, or simplifies computation).

Let's think of a neural data ($\mathbf{Y}$) composed of $N$ neurons over $T$ time points. ($\mathbf{Y} \in \mathbb{R}^{N \times T}$). The core idea of matrix factorization is to approximate the data matrix as:
$$\mathbf{Y}\approx\mathbf{W}\mathbf{H}$$
Where:
* $\mathbf{W} \in \mathbb{R}^{N \times K}$
* $\mathbf{H} \in \mathbb{R}^{K \times T}$
* $K \ll min(N, K)$ ($K < N < T$, in most datasets we deal with)

There are many ways to achieve the factorization (i.e. obtain $\mathbf{W}$ and $\mathbf{H}$), and one can choose a method based on the needs of their problem. Next, I will introduce PCA, which is probably the most popular method used in neuroscience research today.

### PCA as an example factorization technique



## '4 views' of matrix multiplication
After running a matrix factorization algorithm (PCA, NMF, or whatever else...), we have the original data ($\mathbf{Y}$) represented as a product of two matrices ($\mathbf{W}$, $\mathbf{H}$), which hopefully gives us an interesting insight. While exact interpretation depends on the particular method and nature of your data, I will talk about 4 different ways of looking at these matrices, which I learned in an awesome class taught by [Alex Williams][AHW].

### 1. Dot product view



### 2. asdad


[AHW]: https://alexhwilliams.info/




## How CCA works - conceptually
Broadly speaking, CCA is a method that allows us to find bases vectors in two sets of data (matrices) in a way that maximizes the correlation between the two. Suppose you have a matrix of neural activity (e.g. firing rates of many neurons over time) and another matrix of behavior variables (e.g. positions of the animal). CCA finds pairs of linear combinations-one from each dataset-such that the resulting projects are maximally correlated with each other.

Let's say an animal is moving between left and right parts of a room and receiving food at respective percentages that are changing over time (an example inspired by Shadihi et al., 2024). We may have Q behavioral features to focus on (e.g. location of the animal, reward ratio for right, reward ratio for left). During this behavioral observation, we may record activity of $P$ neurons over $T$ time points. We now have a data matrix for neural activity ($\mathbf{X}_p \in \mathbb{R}^{T \times P}$) and behavioral data ($\mathbf{X}_q \in \mathbb{R}^{T \times Q}$).

- $\mathbf{X}_p \in \mathbb{R}^{T \times P}$: neural data matrix ($T$ timebins, $P$ neurons)
- $\mathbf{X}_q \in \mathbb{R}^{T \times Q}$: behavioral data matrix ($T$ timebins, $Q$ behavioral features)

The sheoru




This is advantageous as the results are often interpretable and could link the combination of original features between the two matrices.

Pros
* adad
* adada

Cons
* asda
* dasdad
* adsad


## How CCA works - mathematical derivation



## How is CCA related to PCA


## Exmaple use cases in neuroscience research
### Prefrontal cortex of monkeys during decision making (~ et al., 20XX)


### Basal ganglia of songbird and their acoustic features


### adadasda


## Caveats


## TL'DR


## Further readings


## References

Let:

- $\mathbf{X}_p \in \mathbb{R}^{T \times P}$: neural data matrix ($T$ timebins, $P$ neurons)
- $\mathbf{X}_q \in \mathbb{R}^{T \times Q}$: behavioral data matrix ($T$ timebins, $Q$ behavioral features)

CCA finds weight matrices $\mathbf{W}_p \in \mathbb{R}^{P \times K}$, $\mathbf{W}_q \in \mathbb{R}^{Q \times K}$ such that the projections:

$$
\mathbf{H}_p = \mathbf{X}_p \mathbf{W}_p, \quad \mathbf{H}_q = \mathbf{X}_q \mathbf{W}_q
$$

maximize the correlation between corresponding columns of $\mathbf{H}_p$ and $\mathbf{H}_q$.

For the first canonical pair:

$$
\max_{\mathbf{w}_p, \mathbf{w}_q} \ \frac{\mathbf{w}_p^\top \mathbf{\Sigma}_{pq} \mathbf{w}_q}
{\sqrt{\mathbf{w}_p^\top \mathbf{\Sigma}_{pp} \mathbf{w}_p} \cdot \sqrt{\mathbf{w}_q^\top \mathbf{\Sigma}_{qq} \mathbf{w}_q}}
$$

Where:

- $\mathbf{\Sigma}_{pp} = \frac{1}{T - 1} \mathbf{X}_p^\top \mathbf{X}_p$
- $\mathbf{\Sigma}_{qq} = \frac{1}{T - 1} \mathbf{X}_q^\top \mathbf{X}_q$
- $\mathbf{\Sigma}_{pq} = \frac{1}{T - 1} \mathbf{X}_p^\top \mathbf{X}_q$

Each subsequent canonical direction is computed subject to orthogonality constraints with previous directions.

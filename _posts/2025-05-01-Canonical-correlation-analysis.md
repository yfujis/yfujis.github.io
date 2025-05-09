---
title: 'Canonical Correlation Analysis'
tags: [Math]
status: publish
type: post
published: true

toc: true
toc_label: "outline"
toc_icon: "guitar"
comments: false
header:
  overlay_image: /assets/images/blog/20230413/2023-04-10-bryant.jpg
  overlay_filter: rgba(0,0,0,0.8)
  teaser: /assets/images/blog/20230413/2023-04-10-bryant.jpg
classes:
  - wide

permalink: /blog/:year/:month/:day/:title

excerpt: In this blog post, I write about canonical correlation analysis - how it works and might be used in neuroscience research.
---

## Motivations

With the advent of new technologies, we neuroscientists now have exciting opportunities to probe the brain by recording the activity of tens, hundreds, or even thousands of neurons simultaneously. Beyond just neural recordings, we are increasingly able to quantify behavior in rich and complex ways—ranging from motion tracking to acoustic profiling and many others.

Systems neuroscientists are strongly interested in understanding how the brain generates and controls behavior. This is probably the most exciting time to be in the field of neuroscience—and it will likely only get more exciting.

However, one major challenge we face is making sense of these enormous high-dimensional datasets—namely, finding meaningful relationships between brain activity and behavior when both exist in complex, high-dimensional spaces. To this end, many researchers have developed or adapted analytical frameworks to help answer questions in neuroscience.

CCA is one such example and is a matrix factorization technique that connects two data matrices. CCA finds rotation matrices (set of projection vectors) for individual data matrices such that the two datasets are maximally correlated in the projected subspace (canonical component space). Below is a schematic inspired by [Shahidi et al., 2024][shahidi_et_al_2024].

![Shahidi_et_al_2024_Fig4](../assets/images/blog/Shahidi_et_al_2024_Fig4.png)
*A schematic of CCA (From Shahidi et al., 2024)*

The use of CCA has been increasing in recent studies. For example, [Shahidi et al., 2024][shahidi_et_al_2024] uses CCA to find relationships between neural activity in the prefrontal cortex and behavioral variables in freely moving animals. [Hira et al., 2024][hira_et_al_2024] applied CCA between neural activities two different brain areas.


## Refreshing on Matrix Factorization

*Skip this section if you are already comfortable with PCA, especially if you have good intuition about the implications of running PCA on a data matrix and its transpose.*

### What is Matrix Factorization?

A general understanding of **matrix factorization** will be helpful for understanding how CCA works and how to interpret it. I’ll briefly touch on this with principal component analysis (PCA) as an example.

Matrix factorization is a general technique in linear algebra where a given matrix is decomposed (or 'factored') into a product of two or more matrices. The idea is to represent (or approximate) the original data in a way that is useful—for example, to reveal hidden structure, reduce dimensionality, or simplify computation.

Let’s consider a matrix of neural activity ($\mathbf{Y}$) consisting of $n$ neurons recorded over $T$ time points ($\mathbf{Y} \in \mathbb{R}^{N \times T}$). The core idea of matrix factorization is to approximate the data matrix as:

$$\mathbf{Y} \approx \mathbf{W} \mathbf{H}$$

Where:

- $\mathbf{W} \in \mathbb{R}^{N \times K}$
- $\mathbf{H} \in \mathbb{R}^{K \times T}$
- $K \ll \min(N, T)$ (usually, $K < N < T$ in datasets we deal with)

Using the obtained matrices ($\mathbf{W}$ and $\mathbf{H}$), we can reconstruct the original data:

$$\mathbf{Y} \approx \mathbf{W} \times \mathbf{H} = \mathbf{\tilde{Y}}$$

The reconstruction ($\mathbf{\tilde{Y}}$) is an approximation of the original data ($\mathbf{Y}$), but it now essentially lives in a $K$-dimensional subspace instead of the original $N$- or $T$-dimensional space.

There are a number of ways to achieve this factorization (i.e., to obtain $\mathbf{W}$ and $\mathbf{H}$), and each of them has pros and cons. Here, I will briefly introduce PCA, which is probably the most widely used matrix factorization technique in neuroscience data analysis.


### PCA as an Example Factorization Technique

Principal Component Analysis (PCA) is one of the most commonly used matrix factorization techniques in neuroscience. It is often applied to reduce the dimensionality of neural data while preserving as much of its structure (i.e., variance) as possible.

Let’s return to our neural dataset $\mathbf{Y} \in \mathbb{R}^{N \times T}$, where $N$ is the number of neurons and $T$ is the number of time points. PCA approximates $\mathbf{Y}$ as the product of two low-rank matrices:

$$
\mathbf{Y} \approx \mathbf{W} \mathbf{H}
$$

- $\mathbf{W} \in \mathbb{R}^{N \times K}$ contains the **neural loadings**—how strongly each neuron contributes to each component.
- $\mathbf{H} \in \mathbb{R}^{K \times T}$ contains the **principal components**—the time series of the latent dimensions.
- $K$ is the number of retained components (typically $K \ll N$ and $K \ll T$).

PCA can be understood through **two equivalent objectives**:

#### 1. Minimize Reconstruction Error

PCA finds the best low-rank approximation of the original data by minimizing the following reconstruction error:

$$
\min_{\mathbf{W}, \mathbf{H}} \left\| \mathbf{Y} - \mathbf{W} \mathbf{H} \right\|_F^2
$$

subject to the constraint that the columns of $\mathbf{W}$ are orthogonal (i.e., $\mathbf{W}^T\mathbf{W} = \mathbf{I}$). Here, $\|\cdot\|_F$ is the Frobenius norm, which measures total squared error across all entries. In this formation, $\mathbf{W}$ represents the principal directions (basis vectors), and $\mathbf{H} = \mathbf{W}^T\mathbf{Y}$ contains the low-dimensional representations of the data. A key property of PCA is that the components in $\mathbf{H}$ are uncorrelated---each dimension captures unique variance in the data.

#### 2. Maximize Projected Variance

Alternatively, PCA can be seen as finding directions (components) that capture the most variance in the data. Specifically, PCA solves:

$$
\max_{\mathbf{h}} \ \mathrm{Var}(\mathbf{Y}\mathbf{h})
$$

subject to: $\|\mathbf{h}\|_2 = 1$

This maximization seek a direction $\mathbf{h}$ such that the projection of the data onto $\mathbf{h}$ has the largest variance. Subsequent components are found by imposing orthogonality constraints to previous ones.

---
Both formulations lead to the same result: **a set of $K$ orthogonal components that explain the most variance possible** in the original dataset. To learn how these two ways are equivalent, check out [this blog post][PCA] by Alex-it's a great explanation.

PCA is often the first step in analyzing high-dimensional neural recordings, serving as a foundation for understanding population dynamics, uncovering latent structure, or feeding into downstream models.


## How CCA works - math

Now, we look under the hood of CCA.

### Set the problem

Suppose an animal is moving between left and right parts of a room and receiving food at varying rates over time. We may have Q behavioral features of interest (e.g. speed, location (x, y), amount of received reward, etc.). During this behavioral observation, we may record the activity of $P$ neurons over $T$ time points. This gives us a data matrix for neural activity ($\mathbf{X} \in \mathbb{R}^{T \times P}$) and a behavioral data matrix ($\mathbf{Y} \in \mathbb{R}^{T \times Q}$).

- $\mathbf{X} \in \mathbb{R}^{T \times P}$: neural data matrix ($T$ time bins, $P$ neurons)
- $\mathbf{Y} \in \mathbb{R}^{T \times Q}$: behavioral data matrix ($T$ time bins, $Q$ behavioral features)

Our goal is to find basis vectors for the two matrices that maximize the correlation between the projected activities.

Let:

$$\mathbf{z_X}=\mathbf{X}\mathbf{a}\in\mathbb{R}^{T}$$
$$\mathbf{z_Y}=\mathbf{Y}\mathbf{b}\in\mathbb{R}^{T}$$

where $\mathbf{a}$ and $\mathbf{b}$ are basis vectors for $\mathbf{X}$, $\mathbf{Y}$, respectively. We want to find $\mathbf{a}$ and $\mathbf{b}$ such that the projections $\mathbf{z_X}$ and $\mathbf{z_Y}$› are maximally correlated.

Hence,

$$\max\rho = {\Sigma_{\mathbf{z_X}\mathbf{z_Y}}\over {\sqrt{Var(\mathbf{z_X})}\sqrt{Var(\mathbf{z_Y})}}} = {\mathbf{z_X}^T\mathbf{z_Y} \over {\sqrt{||\mathbf{z_X}||^2}\cdot\sqrt{||\mathbf{z_Y}||^2}}}$$


We also constrain ${||\mathbf{z_X}||^2=||\mathbf{z_Y}||^2=1}$ because the correlation between $\mathbf{z_X}$ and $\mathbf{z_Y}$ is invariant to their scaling. Without this constraint, the norms of $\mathbf{a}$ and $\mathbf{b}$ could be arbitrarily large, making the solution non-unique.

We solve:
$$\max_{\mathbf{a}, \mathbf{b}} \mathbf{a}^T\mathbf{X}^T\mathbf{Y}\mathbf{b}$$
with subject to:

$$\mathbf{a}^T\mathbf{X}^T\mathbf{X}\mathbf{a} = \mathbf{b}^T\mathbf{Y}^T\mathbf{Y}\mathbf{b} = 1$$

### Solving the objective function
As a first step, we replace $a$ and $b$ with the following (it may seem arbitrary now, but we'll see why this is useful in subsequent steps):

$$\mathbf{a} = (\mathbf{X}^T\mathbf{X})^{-1/2}\mathbf{\tilde{a}},\space\space\space\space \mathbf{b} = (\mathbf{Y}^T\mathbf{Y})^{-1/2}\mathbf{\tilde{b}}$$

The optimization problem becomes:
$$\max_{\mathbf{\tilde{a}}, \mathbf{\tilde{b}}} \mathbf{\tilde{a}}^T(\mathbf{X}^T\mathbf{X})^{-1/2}\mathbf{X}^T\mathbf{Y}(\mathbf{Y}^T\mathbf{Y})^{-1/2}\mathbf{\tilde{b}}$$

subject to:

$$\mathbf{\tilde{a}}^T\mathbf{\tilde{a}} = \mathbf{\tilde{b}}^T\mathbf{\tilde{b}} = 1$$

Now, notice that the whitened matrices[^1] of $\mathbf{X}$ and $\mathbf{Y}$ are:

$$\mathbf{\tilde{X}}=\mathbf{X}(\mathbf{X}^T\mathbf{X})^{-1/2},\space\space\space\space \mathbf{\tilde{Y}}=\mathbf{Y}(\mathbf{Y}^T\mathbf{Y})^{-1/2}$$

Therefore we can rewrite the objective as:

$$\max_{\mathbf{\tilde{a}}, \mathbf{\tilde{b}}} \mathbf{\tilde{a}}^T\mathbf{\tilde{X}}^T\mathbf{\tilde{Y}}\mathbf{\tilde{b}}$$

subject to:

$$\mathbf{\tilde{a}}^T\mathbf{\tilde{a}} = \mathbf{\tilde{b}}^T\mathbf{\tilde{b}} = 1$$

We then perform singular value decomposition (SVD) on the cross-covariance matrix:

$$\mathbf{\tilde{X}}^T\mathbf{\tilde{Y}} = \mathbf{U}\mathbf{\Lambda} \mathbf{V}^T$$

So the objective becomes:

$$\max_{\mathbf{\tilde{a}}, \mathbf{\tilde{b}}} \mathbf{\tilde{a}}^T\mathbf{U}\mathbf{\Lambda} \mathbf{V}^T\mathbf{\tilde{b}}$$

subject to:

$$\mathbf{\tilde{a}}^T\mathbf{\tilde{a}} = \mathbf{\tilde{b}}^T\mathbf{\tilde{b}} = 1$$

Let's examine the components:

$$\mathbf{\tilde{a}}^T\mathbf{U}\mathbf{\Lambda} \mathbf{V}^T\mathbf{\tilde{b}}=\begin{bmatrix} \mathbf{\tilde{a}}^T\mathbf{u_1} & \mathbf{\tilde{a}}^T\mathbf{u_2} & \cdots & \mathbf{\tilde{a}}^T\mathbf{u_P} \end{bmatrix}
\left[
\begin{array}{cccc}
\sigma_1 & 0 & \cdots & 0 \\
0 & \sigma_2 & \cdots & 0 \\
\vdots & \vdots & \ddots & \vdots \\
0 & 0 & \cdots & \sigma_Q \\
0 & 0 & \cdots & 0 \\
\vdots & \vdots & & \vdots \\
0 & 0 & \cdots & 0
\end{array}
\right]
\begin{bmatrix}
\mathbf{v_1}^T\tilde{b} \\
\mathbf{v_2}^T\tilde{b} \\
\vdots \\
\mathbf{v_Q}^T\tilde{b}
\end{bmatrix}
$$

$$=\begin{bmatrix}
\cos\theta_1 & \cos\theta_2 & \cdots & cos\theta_P
\end{bmatrix}
\left[
\begin{array}{cccc}
\sigma_1 & 0 & \cdots & 0 \\
0 & \sigma_2 & \cdots & 0 \\
\vdots & \vdots & \ddots & \vdots \\
0 & 0 & \cdots & \sigma_Q \\
0 & 0 & \cdots & 0 \\
\vdots & \vdots & & \vdots \\
0 & 0 & \cdots & 0
\end{array}
\right]
\begin{bmatrix}
\cos\phi_1 \\
\cos\phi_2 \\
\vdots \\
\cos\phi_Q
\end{bmatrix}
$$

$$=\sigma_1\cos\theta_1\cos\phi_1 + \sigma_2\cos\theta_2\cos\phi_2 + \cdots + \sigma_Q\cos\theta_Q\cos\phi_Q
$$

$$=\sum_{i=1}^r\sigma_i\cos\theta_i\cos\phi_i$$

Using the Cauchy-Schwarz inequality:

$$|\sum_{i=1}^r\sigma_i\cos\theta_i\cos\phi_i| \le (\sum_{i=1}^r\sigma_i^2)^{1/2}(\sum_{i=1}^r \cos^2\theta_i\cos^2\phi_i)^{1/2}
$$

But since $||\mathbf{\tilde{a}}|| = ||\mathbf{\tilde{b}}|| = 1$, we have:

$$
\sum_{i=1}^r \cos^2\theta_i\le1, \sum_{i=1}^r \cos^2\phi_i\le1
$$

The upper bound is achieved when all the weight is on the largest $\sigma_1$ term, i.e.,

$$
\cos\theta_1 = \cos\phi_1 = 1
$$

That is, when:

$$
\mathbf{\tilde{a}} = \mathbf{u_1}, \mathbf{\tilde{b}} = \mathbf{v_1}
$$

So the optimal solution is:
$$
\mathbf{a_i} = (\mathbf{X}^T\mathbf{X})^{-1/2}\mathbf{u_i},\space\space\space\space \mathbf{b_i} = (\mathbf{Y}^T\mathbf{Y})^{-1/2}\mathbf{v_1}
$$

where $\sigma_i$ is the $i$th singular value—the $i$th canonical correlation.

In conclusion, CCA is equivalent to performing SVD on the cross-covariance matrix of two whitened matrices.

### Alternative approach - Using Lagrangian multiplier
*Feel free to skip this section unless you're particularly interested in the topic.*

To solve the objective function while incorporating both the *objective* ($\max_{\mathbf{a}, \mathbf{b}} \mathbf{a}^T\Sigma_{XY}\mathbf{b}$) and the *constraint* ($\mathbf{a}^T\Sigma_{XX}\mathbf{a} = 1, \mathbf{b}^T\Sigma_{YY}\mathbf{b} = 1$), we turn to the method of *Lagrangian multiplier*.

---
#### Brief Overview of Lagrange multiplier
The method of Lagrange multiplier is a strategy for finding the maxima and minima of a function subject to equation constraints.

$$def: L(x, \lambda) \equiv f(x) + \lambda g(x)$$

where $f(x)$ is the objective function, $g(x)$ is the constraint, and $\lambda$ is the Lagrange multiplier.

To find maximum (or minimum) of $f(x)$ subject to $g(x)=0$, we find the *stationary point of $L(x, y)$—that is, where all partial derivatives are zero.

---

Back to our problem. Since we have two constraints,

$$\mathbf{a}^T\Sigma_{XX}\mathbf{a}=1, \mathbf{b}^T\Sigma_{YY}\mathbf{b} = 1,$$

we introduce two Lagrange multipliers: $\lambda_1$ and $\lambda_2$.

$$L(\mathbf{a}, \mathbf{b}, \lambda_1, \lambda_2) = \mathbf{a}^T\Sigma_{XY}\mathbf{b} - {\lambda_1\over2}(\mathbf{a}^T\Sigma_{XX}\mathbf{a}-1) - {\lambda_2\over2}(\mathbf{b}^T\Sigma_{YY}\mathbf{b}-1)$$

Take the derivative with respect to $\mathbf{a}$:

$${\delta L\over{\delta{\mathbf{a}}}} = {\delta\over{\delta{\mathbf{a}}}}(\mathbf{a}^T\Sigma_{XY}\mathbf{b}) - {\delta\over{\delta{\mathbf{a}}}}({\lambda_1\over2}(\mathbf{a}^T\Sigma_{XX}\mathbf{a}-1)) - {\delta\over{\delta{\mathbf{a}}}}({\lambda_2\over2}(\mathbf{b}^T\Sigma_{YY}\mathbf{b}-1))$$

$$= \Sigma_{XY}\mathbf{b} - \lambda_1\Sigma_{XX}\mathbf{a} = 0$$

Use the vector derivative identities:

$${\delta\over \delta \mathbf{x}}\mathbf{x}^TA\mathbf{y} = A\mathbf{y}, {\delta\over \delta \mathbf{x}}\mathbf{x}^TA\mathbf{x} = 2A\mathbf{x}$$

The third term vanishes since it contains no $\mathbf{a}$.
Thus:

$$\Sigma_{XY}\mathbf{b} = \lambda∂_1\Sigma_{XX}\mathbf{a} \space\space\space(1)$$

Similarity, take the derivative with respect to $\mathbf{b}$:

$${\delta L\over{\delta{\mathbf{b}}}} = {\delta\over{\delta{\mathbf{b}}}}(\mathbf{a}^T\Sigma_{XY}\mathbf{b}) - {\delta\over{\delta{\mathbf{b}}}}({\lambda_1\over2}(\mathbf{a}^T\Sigma_{XX}\mathbf{a}-1)) - {\delta\over{\delta{\mathbf{b}}}}({\lambda_2\over2}(\mathbf{b}^T\Sigma_{YY}\mathbf{b}-1))$$

$$= \Sigma_{YY}\mathbf{a} - \lambda_2\Sigma_{YY}\mathbf{b} = 0$$

So:
$$\Sigma_{YX}\mathbf{a} = \lambda_2\Sigma_{YY}\mathbf{b} \space\space\space\space(2)$$

Take transpose of (1) and multiply on the right by $\mathbf{a}$:

$$\mathbf{b}^T\Sigma_{YX}\mathbf{a}=\lambda_1\mathbf{a}^T\Sigma_{XX}\mathbf{a}$$

Take (2) and multiply on the left by $\mathbf{b}^T$:

$$\mathbf{b}^T\Sigma_{YX}\mathbf{a} = \lambda_2\mathbf{b}^T\Sigma_{YY}\mathbf{b}$$

Since the contraints are $\mathbf{a}^T\Sigma_{XX}\mathbf{a} = 1, \mathbf{b}^T\Sigma_{YY}\mathbf{b} = 1$, it follows that:

$$\lambda_1 = \mathbf{b}^T\Sigma_{YX}\mathbf{a} = \lambda_2$$

Let:
$$\lambda = \lambda_1 = \lambda_2$$

From (2), assuming $\Sigma_{YY}$ is invertible:

$$\mathbf{b} = {1\over{\lambda}}\Sigma_{YY}^{-1}\Sigma_{YX}\mathbf{a} \space\space\space\space (3)$$

Plug (3) into (1):

$$\Sigma_{XY}({1\over{\lambda}}\Sigma_{YY}^{-1}\Sigma_{YX}\mathbf{a}) = \lambda\Sigma_{XX}\mathbf{a}$$

$$(\Sigma_{XY}\Sigma_{YY}^{-1}\Sigma_{YX})\mathbf{a} = \lambda^2\Sigma_{XX}a \space\space\space\space (4)$$


Equation (4) is **generalized eigenvalue problem**!!

We solve this for eigenvalues $\lambda^2$ and eigenvectors $\mathbf{a}$. Once obtain $\mathbf{a}$ and $\lambda$, we can substitute them to (3) to obtain $\mathbf{b}$.

One caveat of this method is we only obtain one canonical component at a time.
Although analytically rigorous, I found the alternative method—SVD of the cross-covariance matrix of whitened matrices—more intuitive when learning this topic. Moreover, the SVD-based approach builds a conceptual bridge between CCA and related techniques such as PCA[^2] and even Procrustes distance[^3].

## Conceptual links with other methods

### PCA

One might notice that both PCA and CCA can be solved using singular value decomposition (SVD). This is because the goal of both methods is to find a set of **orthogonal** basis vectors that best explain the structure in the data. In PCA, the 'data' refers to a single data matrix, and the goal is to capture its variance. In CCA, the 'data' is the cross-covariance matrix between two whitened data matrices—that is, it seeks directions that maximize the correlation between the two datasets.

### Procrustes distance


### How is CCA different from linear decoding.


## Pros and Cons of CCA



## TL'DR


## References


### Footnotes
[^1]: Whitening is a linear transformation that removes correlations between variables and scales them to have unit variance. For a zero-mean matrix \( \mathbf{X} \), the whitened version is \( \tilde{\mathbf{X}} = \mathbf{X} (\mathbf{X}^\top \mathbf{X})^{-1/2} \), which ensures that \( \tilde{\mathbf{X}}^\top \tilde{\mathbf{X}} = \mathbf{I} \). A useful intuition is to think of whitening as a multivariate version of z-scoring. In the context of CCA, whitening ensures that we capture only the relationships *between* the two datasets, without being influenced by the structure *within* each dataset. See [Wikipedia][Whitening_wiki].
[^2]: asdsa
[^3]: adadeeaded

[shahidi_et_al_2024]: https://doi.org/10.1038/s41593-024-01575-w
[hira_et_al_2024]: https://www.biorxiv.org/content/10.1101/2023.08.27.555017v2
[AHW]: https://alexhwilliams.info/
[PCA]: https://alexhwilliams.info/itsneuronalblog/2016/03/27/pca/
[Whitening_wiki]: https://en.wikipedia.org/wiki/Whitening_transformation
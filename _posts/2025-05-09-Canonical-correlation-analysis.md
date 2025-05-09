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
  overlay_image: /assets/images/blog/cca_illustration.png
  overlay_filter: rgba(0,0,0,0.8)
  teaser: /assets/images/blog/cca_illustration.png
classes:
  - wide

permalink: /blog/:year/:month/:day/:title

excerpt: I explore canonical correlation analysis—a matrix factorization method that links two data matrices—explaining how it works, how it relates conceptually to other methods, and how it can be applied in neuroscience research.
---

## Motivations

With the advent of new technologies, we, systems neuroscientists, now have exciting opportunities to probe the brain by recording the activity of tens, hundreds, or even thousands of neurons simultaneously. Beyond just neural recordings, we are increasingly able to quantify behavior in rich and complex ways—ranging from motion tracking to acoustic profiling and many others.

However, one major challenge we face is making sense of these enormous high-dimensional datasets—namely, finding meaningful relationships between brain activity and behavior when both exist in complex, high-dimensional spaces. To this end, many researchers have developed or adapted analytical frameworks to help answer questions in neuroscience.

CCA is one such example—a matrix factorization technique that connects two data matrices. It finds linear transformation matrices (i.e., sets of projection vectors) for each data matrix such that the two datasets are maximally correlated in their respective projected subspaces (known as canonical component spaces). Below is a schematic illustration of CCA (notations will be introduced later in this blog post).

![cca_illustration](/assets/images/blog/cca_illustration.png)
*A schematic of CCA.*

The use of CCA has been increasing in recent studies. For example, [Shahidi et al., 2024][shahidi_et_al_2024] uses CCA to find relationships between neural activity in the prefrontal cortex and behavioral variables in freely moving animals. [Hira et al., 2024][hira_et_al_2024] applied CCA between neural activities two different brain areas to estimate the amount of shared information between an area and the other areas.


## How CCA Works

Now, we look under the hood of CCA.

### Problem Setup

Suppose an animal is moving between left and right parts of a room and receiving food at varying rates over time. We may have Q behavioral features of interest (e.g. speed, location (x, y), amount of received reward, etc.). During this behavioral observation, we may record the activity of $P$ neurons over $T$ time points. This gives us a data matrix for neural activity ($\mathbf{X} \in \mathbb{R}^{T \times P}$) and a behavioral data matrix ($\mathbf{Y} \in \mathbb{R}^{T \times Q}$).

- $\mathbf{X} \in \mathbb{R}^{T \times P}$: neural data matrix ($T$ time bins, $P$ neurons)
- $\mathbf{Y} \in \mathbb{R}^{T \times Q}$: behavioral data matrix ($T$ time bins, $Q$ behavioral features)

Our goal is to find basis vectors for the two matrices that maximize the correlation between the projected activities.

Let:

$$\mathbf{z_X}=\mathbf{X}\mathbf{a}\in\mathbb{R}^{T}$$
$$\mathbf{z_Y}=\mathbf{Y}\mathbf{b}\in\mathbb{R}^{T}$$

where $\mathbf{a}$ and $\mathbf{b}$ are basis vectors for $\mathbf{X}$, $\mathbf{Y}$, respectively. We want to find $\mathbf{a}$ and $\mathbf{b}$ such that the projections $\mathbf{z_X}$ and $\mathbf{z_Y}$› are maximally correlated.

Hence,

$$\max\rho = {\Sigma_{\mathbf{z_X}\mathbf{z_Y}}\over {\sqrt{Var(\mathbf{z_X})}\sqrt{Var(\mathbf{z_Y})}}} = {\mathbf{z_X}^\top\mathbf{z_Y} \over {\sqrt{\vert\vert\mathbf{z_X}\vert\vert^2}\cdot\sqrt{\vert\vert\mathbf{z_Y}\vert\vert^2}}}$$


We also constrain ${\vert\mathbf{z_X}\vert\vert^2=\vert\vert\mathbf{z_Y}\vert\vert^2=1}$ because the correlation between $\mathbf{z_X}$ and $\mathbf{z_Y}$ is invariant to their scaling. Without this constraint, the norms of $\mathbf{a}$ and $\mathbf{b}$ could be arbitrarily large, making the solution non-unique.

We solve:

$$\max_{\mathbf{a}, \mathbf{b}} \mathbf{a}^\top\mathbf{X}^\top\mathbf{Y}\mathbf{b}$$

subject to:

$$\mathbf{a}^\top\mathbf{X}^\top\mathbf{X}\mathbf{a} = \mathbf{b}^\top\mathbf{Y}^\top\mathbf{Y}\mathbf{b} = 1$$


### Solving the objective function

As a first step, we replace $a$ and $b$ with the following (it may seem arbitrary now, but we'll see why this is useful in subsequent steps):

$$\mathbf{a} = (\mathbf{X}^\top\mathbf{X})^{-1/2}\mathbf{\tilde{a}},\space\space\space\space \mathbf{b} = (\mathbf{Y}^\top\mathbf{Y})^{-1/2}\mathbf{\tilde{b}}$$

The optimization problem becomes:

$$\max_{\mathbf{\tilde{a}}, \mathbf{\tilde{b}}} \mathbf{\tilde{a}}^\top(\mathbf{X}^\top\mathbf{X})^{-1/2}\mathbf{X}^\top\mathbf{Y}(\mathbf{Y}^\top\mathbf{Y})^{-1/2}\mathbf{\tilde{b}}$$

subject to:

$$\mathbf{\tilde{a}}^\top\mathbf{\tilde{a}} = \mathbf{\tilde{b}}^\top\mathbf{\tilde{b}} = 1$$

Now, notice that the whitened matrices[^1] of $\mathbf{X}$ and $\mathbf{Y}$ are:

$$\mathbf{\tilde{X}}=\mathbf{X}(\mathbf{X}^\top\mathbf{X})^{-1/2},\space\space\space\space \mathbf{\tilde{Y}}=\mathbf{Y}(\mathbf{Y}^\top\mathbf{Y})^{-1/2}$$

Therefore we can rewrite the objective as:

$$\max_{\mathbf{\tilde{a}}, \mathbf{\tilde{b}}} \mathbf{\tilde{a}}^\top\mathbf{\tilde{X}}^\top\mathbf{\tilde{Y}}\mathbf{\tilde{b}}$$

subject to:

$$\mathbf{\tilde{a}}^\top\mathbf{\tilde{a}} = \mathbf{\tilde{b}}^\top\mathbf{\tilde{b}} = 1$$

We then perform singular value decomposition (SVD) on the cross-covariance matrix:

$$\mathbf{\tilde{X}}^\top\mathbf{\tilde{Y}} = \mathbf{U}\mathbf{\Lambda} \mathbf{V}^\top$$

So the objective becomes:

$$\max_{\mathbf{\tilde{a}}, \mathbf{\tilde{b}}} \mathbf{\tilde{a}}^\top\mathbf{U}\mathbf{\Lambda} \mathbf{V}^\top\mathbf{\tilde{b}}$$

subject to:

$$\mathbf{\tilde{a}}^\top\mathbf{\tilde{a}} = \mathbf{\tilde{b}}^\top\mathbf{\tilde{b}} = 1$$

Let's examine the components:

$$\mathbf{\tilde{a}}^\top\mathbf{U}\mathbf{\Lambda} \mathbf{V}^\top\mathbf{\tilde{b}}=\begin{bmatrix} \mathbf{\tilde{a}}^\top\mathbf{u_1} & \mathbf{\tilde{a}}^\top\mathbf{u_2} & \cdots & \mathbf{\tilde{a}}^\top\mathbf{u_P} \end{bmatrix}
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
\mathbf{v_1}^\top\tilde{b} \\
\mathbf{v_2}^\top\tilde{b} \\
\vdots \\
\mathbf{v_Q}^\top\tilde{b}
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

$$\vert\sum_{i=1}^r\sigma_i\cos\theta_i\cos\phi_i\vert \le (\sum_{i=1}^r\sigma_i^2)^{1/2}(\sum_{i=1}^r \cos^2\theta_i\cos^2\phi_i)^{1/2}
$$

But since $\vert\vert\mathbf{\tilde{a}}\vert\vert = \vert\vert\mathbf{\tilde{b}}\vert\vert = 1$, we have:

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
\mathbf{a_i} = (\mathbf{X}^\top\mathbf{X})^{-1/2}\mathbf{u_i},\space\space\space\space \mathbf{b_i} = (\mathbf{Y}^\top\mathbf{Y})^{-1/2}\mathbf{v_1}
$$

where $\sigma_i$ is the $i$th singular value—the $i$th canonical correlation.

In conclusion, CCA is equivalent to performing SVD on the cross-covariance matrix of two whitened matrices.

### Alternative approach - Using Lagrangian multiplier
*Feel free to skip this section unless you're particularly interested in the topic.*

To solve the objective function while incorporating both the *objective* ($\max_{\mathbf{a}, \mathbf{b}} \mathbf{a}^\top\Sigma_{XY}\mathbf{b}$) and the *constraint* ($\mathbf{a}^\top\Sigma_{XX}\mathbf{a} = 1, \mathbf{b}^\top\Sigma_{YY}\mathbf{b} = 1$), we turn to the method of *Lagrangian multiplier*.

---
***Brief Overview of Lagrange multiplier***

The method of Lagrange multiplier is a strategy for finding the maxima and minima of a function subject to equation constraints.

$$def: L(x, \lambda) \equiv f(x) + \lambda g(x)$$

where $f(x)$ is the objective function, $g(x)$ is the constraint, and $\lambda$ is the Lagrange multiplier.

To find maximum (or minimum) of $f(x)$ subject to $g(x)=0$, we find the *stationary point* of $L(x, y)$—that is, where all partial derivatives are zero.

---

Back to our problem. Since we have two constraints,

$$\mathbf{a}^\top\Sigma_{XX}\mathbf{a}=1, \mathbf{b}^\top\Sigma_{YY}\mathbf{b} = 1,$$

we introduce two Lagrange multipliers: $\lambda_1$ and $\lambda_2$.

$$L(\mathbf{a}, \mathbf{b}, \lambda_1, \lambda_2) = \mathbf{a}^\top\Sigma_{XY}\mathbf{b} - {\lambda_1\over2}(\mathbf{a}^\top\Sigma_{XX}\mathbf{a}-1) - {\lambda_2\over2}(\mathbf{b}^\top\Sigma_{YY}\mathbf{b}-1)$$

Take the derivative with respect to $\mathbf{a}$:

$${\delta L\over{\delta{\mathbf{a}}}} = {\delta\over{\delta{\mathbf{a}}}}(\mathbf{a}^\top\Sigma_{XY}\mathbf{b}) - {\delta\over{\delta{\mathbf{a}}}}({\lambda_1\over2}(\mathbf{a}^\top\Sigma_{XX}\mathbf{a}-1)) - {\delta\over{\delta{\mathbf{a}}}}({\lambda_2\over2}(\mathbf{b}^\top\Sigma_{YY}\mathbf{b}-1))$$

$$= \Sigma_{XY}\mathbf{b} - \lambda_1\Sigma_{XX}\mathbf{a} = 0$$

Use the vector derivative identities:

$${\delta\over \delta \mathbf{x}}\mathbf{x^\top} \mathbf{A}\mathbf{y} = \mathbf{A}\mathbf{y} {\delta\over \delta \mathbf{x}}\mathbf{x^\top}\mathbf{A}\mathbf{x} = 2\mathbf{A}\mathbf{x}$$

The third term vanishes since it contains no $\mathbf{a}$.
Thus:

$$\Sigma_{XY}\mathbf{b} = \lambda_1\Sigma_{XX}\mathbf{a} \space\space\space(1)$$

Similarity, take the derivative with respect to $\mathbf{b}$:

$${\delta L\over{\delta{\mathbf{b}}}} = {\delta\over{\delta{\mathbf{b}}}}(\mathbf{a}^\top\Sigma_{XY}\mathbf{b}) - {\delta\over{\delta{\mathbf{b}}}}({\lambda_1\over2}(\mathbf{a}^\top\Sigma_{XX}\mathbf{a}-1)) - {\delta\over{\delta{\mathbf{b}}}}({\lambda_2\over2}(\mathbf{b}^\top\Sigma_{YY}\mathbf{b}-1))$$

$$= \Sigma_{YY}\mathbf{a} - \lambda_2\Sigma_{YY}\mathbf{b} = 0$$

So:
$$\Sigma_{YX}\mathbf{a} = \lambda_2\Sigma_{YY}\mathbf{b} \space\space\space\space(2)$$

Take transpose of (1) and multiply on the right by $\mathbf{a}$:

$$\mathbf{b}^\top\Sigma_{YX}\mathbf{a}=\lambda_1\mathbf{a}^\top\Sigma_{XX}\mathbf{a}$$

Take (2) and multiply on the left by $\mathbf{b}^\top$:

$$\mathbf{b}^\top\Sigma_{YX}\mathbf{a} = \lambda_2\mathbf{b}^\top\Sigma_{YY}\mathbf{b}$$

Since the contraints are $\mathbf{a}^\top\Sigma_{XX}\mathbf{a} = 1, \mathbf{b}^\top\Sigma_{YY}\mathbf{b} = 1$, it follows that:

$$\lambda_1 = \mathbf{b}^\top\Sigma_{YX}\mathbf{a} = \lambda_2$$

Let:
$$\lambda = \lambda_1 = \lambda_2$$

From (2), assuming $\Sigma_{YY}$ is invertible:

$$\mathbf{b} = {1\over{\lambda}}\Sigma_{YY}^{-1}\Sigma_{YX}\mathbf{a} \space\space\space\space (3)$$

Plug (3) into (1):

$$\Sigma_{XY}({1\over{\lambda}}\Sigma_{YY}^{-1}\Sigma_{YX}\mathbf{a}) = \lambda\Sigma_{XX}\mathbf{a}$$

$$(\Sigma_{XY}\Sigma_{YY}^{-1}\Sigma_{YX})\mathbf{a} = \lambda^2\Sigma_{XX}a \space\space\space\space (4)$$


Equation (4) is **[generalized eigenvalue problem][gep]**!!

We solve this for eigenvalues $\lambda^2$ and eigenvectors $\mathbf{a}$. Once obtain $\mathbf{a}$ and $\lambda$, we can substitute them to (3) to obtain $\mathbf{b}$.

One caveat of this method is that it yields only one canonical component at a time. While analytically rigorous, I found an alternative approach—performing SVD on the cross-covariance matrix of whitened matrices—more intuitive when first learning this topic. Moreover, the SVD-based formulation provides a conceptual bridge between CCA and related techniques such as PCA and even Procrustes analysis. That’s what I’ll discuss next.

## Conceptual links with other methods

### PCA

One might notice that both PCA and CCA can be solved using singular value decomposition (SVD). This is because both methods aim to find a set of orthogonal basis vectors that best capture structure in a matrix. In PCA, the matrix in question is a single data matrix, and SVD identifies orthogonal directions that explain the variance in the data. In CCA, the relevant matrix is the cross-covariance between two whitened data matrices—SVD then finds orthogonal directions that best explain the correlation between the original datasets. For a helpful intuition on PCA, see [this blog post by Alex][alex_pca].


### Procrustes shape distance
Procrustes analysis is a form of statistical shape analysis used to compare the geometry of two datasets. Specifically, the [orthogonal Procrustes problem][opp] finds the optimal rotation (an orthogonal linear transformation) that best aligns one matrix to another. In neuroscience, this method has become increasingly popular in brain-machine interface (BMI) research. The idea is to align the geometric shape of neural activity from an ongoing recording session to a template (such as activity recorded on the first day), in a dimensionality-reduced subspace. This alignment allows decoders trained on the template to generalize to new sessions with minimal fine-tuning, significantly reducing training time. Because the alignment occurs in a low-dimensional space, the method is robust to neural drift (e.g., neurons being lost or gained on the electrode array) and can even be applied across sessions or between different subjects. See [Degenhart et al., 2020][degenhart] for a cool example.

Let $\mathbf{X}, \mathbf{Y}$ be the ongoing and template activity, respectively, and let $\mathbf{R}$ be the rotation matrix (orthogonal), the objective function is:

$$
\min\vert\vert\mathbf{RX}-\mathbf{Y}\vert\vert^2_F
$$

subject to:


$$\mathbf{R}^\top\mathbf{R} = \mathbf{I}$$

To solve this, expand the squared Frobenius norm:

$$
\min\vert\vert\mathbf{RX}-\mathbf{Y}\vert\vert^2_F=\operatorname{Tr}{[(\mathbf{RX}-\mathbf{Y})^\top(\mathbf{RX}-\mathbf{Y})]} = \operatorname{Tr}(\mathbf{X}^\top\mathbf{X}) + \operatorname{Tr}(\mathbf{Y}^\top\mathbf{Y}) - 2\operatorname{Tr}(\mathbf{X}^\top\mathbf{R}^\top\mathbf{Y})
$$

As the first two terms don't depend on $\mathbf{R}$, this is equivalent to:

$$
\max_{\mathbf{R}^\top\mathbf{R} = \mathbf{I}}\operatorname{Tr}(\mathbf{X}^\top\mathbf{R}^\top\mathbf{Y})
$$

Using the cyclic property of the trace[^2]:

$$
\max_{\mathbf{R}^\top\mathbf{R} = \mathbf{I}}\operatorname{Tr}(\mathbf{R}^\top\mathbf{Y}\mathbf{X}^\top)
$$

This shows that the Procrustes problem reduces to finding the rotation matrix $\mathbf{R}$ that maximmazies the alignment (i.e., the trace) of the cross-covariance matrix between $\mathbf{X}$ and $\mathbf{Y}$.

To solve:

$$
\max_{\mathbf{R}^\top \mathbf{R} = \mathbf{I}} \operatorname{Tr}(\mathbf{R}^\top \mathbf{Y} \mathbf{X}^\top)
$$

we perform the *singular value decomposition (SVD)* of the cross-covariance matrix (assuming zero-meaned) $ \mathbf{Y} \mathbf{X}^\top $:

$$
\mathbf{Y} \mathbf{X}^\top = \mathbf{U} \mathbf{\Sigma} \mathbf{V}^\top
$$

The optimal rotation matrix is then given by:

$$
\mathbf{R}^\star = \mathbf{U} \mathbf{V}^\top
$$

This solution maximizes the alignment between $ \mathbf{R} \mathbf{X} $ and $ \mathbf{Y} $, and is guaranteed to be an orthogonal matrix (i.e., a pure rotation, possibly including reflection).

---

***Why This Works***

We rewrite the trace objective using the SVD:

$$
\operatorname{Tr}(\mathbf{R}^\top \mathbf{Y} \mathbf{X}^\top)
= \operatorname{Tr}(\mathbf{R}^\top \mathbf{U} \mathbf{\Sigma} \mathbf{V}^\top)
= \operatorname{Tr}(\mathbf{\Sigma} \mathbf{V}^\top \mathbf{R}^\top \mathbf{U})
$$

Let $\mathbf{Q} = \mathbf{V}^\top \mathbf{R}^\top \mathbf{U}$, which is orthogonal. Then:

$$
\operatorname{Tr}(\mathbf{\Sigma} \mathbf{Q}) \le \sum_i \sigma_i
\quad \text{with equality when } \mathbf{Q} = \mathbf{I}
$$

This happens when:

$$
\mathbf{R} = \mathbf{U} \mathbf{V}^\top
$$

which achieves the **maximum possible trace**. This is the optimal solution.

---

In short, the Procrustes problem can be solved by performing SVD on the cross-covariance matrix of the two data matrices. **Canonical Correlation Analysis (CCA) can be seen as a special case of the Procrustes problem, where both data matrices are first whitened**. While CCA focuses solely on maximizing the correlation in the projected space—ignoring scaling and the original data’s covariance structure—the Procrustes problem aims to match the original data shapes more directly.

Also, note the difference: the Procrustes problem involves optimizing a single rotation matrix, whereas CCA requires two projection vectors. This is because the Procrustes problem assumes the two data matrices have the same dimensions, which in practice often done by first applying dimensionality reduction (e.g., via PCA).

## Pros and Cons of CCA

The cool thing about CCA is that it can reveal meaningful relationships between data matrices of completely different modalities (e.g., neural activity and behavior) in an interpretable way. For example, one might find that a particular subgroup of neurons (reflected in the neural canonical weights) exhibits ramping activity along a canonical component that correlates with predicted reward availability (captured by the corresponding behavioral canonical component). One can further impose a sparsity constraints to encourage each canonical components to reflect only a few set of variables. See [Witten et al., 2008.][sparse_CCA].

A key limitation of classical CCA, however, is that it only captures linear relationships between the two datasets. This can be problematic in neuroscience, where the relationship between neural activity and behavior is often highly nonlinear. Similarly, behavioral variables may be encoded in complex, nonlinear subspaces of neural activity that cannot be uncovered through linear projections alone.

## TL'DR

- CCA finds orthogonal directions (canonical weights) that maximally correlate two different matrices.
- CCA has elegant conceptual connections to other factorization and statistical methods:
  - It can be viewed as performing **PCA** on the cross-covariance matrix between two whitened datasets.
  - It can also be seen as a **special case of the Procrustes problem**, where the data matrices are first whitened.
- CCA can be a useful tool for uncovering **linear relationships** between two datasets (e.g. neural activities and behavioral features). It does *not* capture any non-linear relationships.

## Footnotes

[^1]: [Whitening][Whitening_wiki] is a linear transformation that removes correlations between variables and scales them to have unit variance. For a zero-mean matrix $\mathbf{X} $, the whitened version is $ \tilde{\mathbf{X}} = \mathbf{X} (\mathbf{X}^\top \mathbf{X})^{-1/2} $, which ensures that $ \tilde{\mathbf{X}}^\top \tilde{\mathbf{X}} = \mathbf{I} $. A useful intuition is to think of whitening as a multivariate version of z-scoring. In the context of CCA, whitening ensures that we capture only the relationships *between* the two datasets, without being influenced by the structure *within* each dataset.
[^2]: [Cyclic property][cyclic_property]: $\operatorname{Tr}(\mathbf{A}\mathbf{B}\mathbf{C}\mathbf{D})=\operatorname{Tr}(\mathbf{B}\mathbf{C}\mathbf{D}\mathbf{A})=\operatorname{Tr}(\mathbf{C}\mathbf{D}\mathbf{A}\mathbf{B})=\operatorname{Tr}(\mathbf{D}\mathbf{A}\mathbf{B}\mathbf{C})$

[shahidi_et_al_2024]: https://doi.org/10.1038/s41593-024-01575-w
[hira_et_al_2024]: https://www.biorxiv.org/content/10.1101/2023.08.27.555017v2
[gep]: https://en.wikipedia.org/wiki/Eigendecomposition_of_a_matrix#Generalized_eigenvalue_problem
[AHW]: https://alexhwilliams.info/
[alex_pca]: https://alexhwilliams.info/itsneuronalblog/2016/03/27/pca/
[Whitening_wiki]: https://en.wikipedia.org/wiki/Whitening_transformation
[opp]: https://en.wikipedia.org/wiki/Orthogonal_Procrustes_problem
[degenhart]: https://www.nature.com/articles/s41551-020-0542-9
[cyclic_property]: https://en.wikipedia.org/wiki/Trace_(linear_algebra)#Cyclic_property
[sparse_CCA]: https://doi.org/10.1093/biostatistics/kxp008
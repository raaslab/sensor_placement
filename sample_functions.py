from math import exp
import numpy as np
import matplotlib.pyplot as plt

def rbf_kernel(x1, x2, variance = 1):
    return exp(-1.3895)**2*exp(-1 * ((x1-x2) ** 2) / 2*exp(1.1341)**2)

def gram_matrix(xs):
    return [[rbf_kernel(x1,x2) for x2 in xs] for x1 in xs]

xs = np.arange(-5, 5, 0.1)
mean = [0 for x in xs]
gram = gram_matrix(xs)

plt_vals = []
for i in range(0, 1):
    ys = np.random.multivariate_normal(mean, gram)
    plt_vals.extend([xs, ys, "k"])
plt.plot(*plt_vals)
plt.show()
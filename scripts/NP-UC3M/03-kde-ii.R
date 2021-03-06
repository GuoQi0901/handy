
## ------------------------------------------------------------------------
## Name: 03-kde-ii.R
## Description: Script for Chapter 3 of "Notes for Predictive Modeling"
## Link: https://bookdown.org/egarpor/NP-UC3M/
## License: https://creativecommons.org/licenses/by-nc-nd/4.0/
## Author: Eduardo García-Portugués
## ------------------------------------------------------------------------

## ---- kde-2d-1-----------------------------------------------------------
# Simulated data from a bivariate normal
n <- 200
set.seed(35233)
x <- mvtnorm::rmvnorm(n = n, mean = c(0, 0),
                      sigma = rbind(c(1.5, 0.25), c(0.25, 0.5)))

# Compute kde for a diagonal bandwidth matrix (trivially positive definite)
H <- diag(c(1.25, 0.75))
kde <- ks::kde(x = x, H = H)

# The eval.points slot contains the grids on x and y
str(kde$eval.points)

# The grids in kde$eval.points are crossed in order to compute a grid matrix
# where to compute the estimate
dim(kde$estimate)

# Manual plotting using the kde object structure
image(kde$eval.points[[1]], kde$eval.points[[2]], kde$estimate,
      col = viridis::viridis(20), xlab = "x", ylab = "y")
points(kde$x) # The data is returned in $x

# Changing the grid size to compute the estimates to be 200 x 200 and in the
# rectangle (-4, 4) x c(-3, 3)
kde <- ks::kde(x = x, H = H, gridsize = c(200, 200), xmin = c(-4, -3),
               xmax = c(4, 3))
image(kde$eval.points[[1]], kde$eval.points[[2]], kde$estimate,
      col = viridis::viridis(20), xlab = "x", ylab = "y")
dim(kde$estimate)

# Do not confuse "gridsize" with "bgridsize". The latter controls the internal
# grid size employing for binning the data and speeding up the computations
# (compare with binned = FALSE for a large sample size), and is not recommended
# to modify unless you know what you are doing. The binning takes place if
# binned = TRUE or if "binned" is not specified and the sample size is large

# Evaluating the kde at specific points can be done with "eval.points"
kde_sample <- ks::kde(x = x, H = H, eval.points = x)
str(kde_sample$estimate)

# Assign colors automatically from quantiles to have an idea the densities of
# each one
n_cols <- 20
quantiles <- quantile(kde_sample$estimate, probs = seq(0, 1, l = n_cols + 1))
col <- viridis::viridis(n_cols)[cut(kde_sample$estimate, breaks = quantiles)]
plot(x, col = col, pch = 19, xlab = "x", ylab = "y")

# Binning vs not binning
abs(max(ks::kde(x = x, H = H, eval.points = x, binned = TRUE)$estimate -
          ks::kde(x = x, H = H, eval.points = x, binned = FALSE)$estimate))

## ---- kde-2d-2-----------------------------------------------------------
# Contourplot
plot(kde, display = "slice", cont = c(25, 50, 75), xlab = "x", ylab = "y")
# "cont" specifies the density contours, which are upper percentages of highest
# density regions. The default contours are at 25%, 50%, and 75%

# Raw image with custom colors
plot(kde, display = "image", xlab = "x", ylab = "y", col = viridis::viridis(20))

# Filled contour with custom color palette in "col.fun"
plot(kde, display = "filled.contour2", cont = seq(5, 95, by = 10),
     xlab = "x", ylab = "y", col.fun = viridis::viridis)
# Alternatively: col = viridis::viridis(length(cont) + 1)

# Add contourlevels
plot(kde, display = "filled.contour", cont = seq(5, 95, by = 10),
     xlab = "x", ylab = "y", col.fun = viridis::viridis)
plot(kde, display = "slice", cont = seq(5, 95, by = 10), add = TRUE)

# Perspective plot
plot(kde, display = "persp", col.fun = viridis::viridis, xlab = "x", ylab = "y")

## ---- kde-3d-------------------------------------------------------------
# Simulated data from a trivariate normal
n <- 500
set.seed(213212)
x <- mvtnorm::rmvnorm(n = n, mean = c(0, 0, 0),
                      sigma = rbind(c(1.5, 0.25, 0.5),
                                    c(0.25, 0.75, 1),
                                    c(0.5, 1, 2)))

# Show nested contours of high density regions
plot(ks::kde(x = x, H = diag(c(rep(1.25, 3)))), drawpoints = TRUE, col.pt = 1)
rgl::rglwidget()

# Careful! Incorrect (not symmetric or positive definite) bandwidths do not
# generate an error, but they return a non-sense kde
head(ks::kde(x = x, H = diag(c(1, 1, -1)), eval.points = x)$estimate)
head(ks::kde(x = x, H = diag(c(1, 1, 0)), eval.points = x)$estimate)

# H not positive definite
H <- rbind(c(1.5, 0.25, 0.5),
           c(0.25, 0.75, -1.5),
           c(0.5, -1.5, 2))
eigen(H)$values
head(ks::kde(x = x, H = H, eval.points = x)$estimate)

# H semipositive definite but not positive definite
H <- rbind(c(1.5, 0.25, 0.5),
           c(0.25, 0.5, 1),
           c(0.5, 1, 2))
eigen(H)$values
head(ks::kde(x = x, H = H, eval.points = x)$estimate) # Numerical instabilities

## ---- ks-bug, eval = FALSE-----------------------------------------------
## # Sample test data
## p <- 4
## data <- mvtnorm::rmvnorm(n = 10, mean = rep(0, p))
## kde <- ks::kde(x = data, H = diag(rep(1, p))) # Error on the verbose argument

## ---- ks-bug-patch, eval = FALSE-----------------------------------------
## # Create a copy of the funcion you want to modify
## kde.points.fixed <- ks:::kde.points
## 
## # Modify the function (in this case, just replace the default arguments via the
## # formals() function)
## f <- formals(fun = kde.points.fixed)
## f$verbose <- FALSE
## formals(fun = kde.points.fixed, envir = environment(kde.points.fixed)) <- f
## 
## # Overwrite original function (careful -- you will have to restart session to
## # come back to the previous object)
## assignInNamespace(x = "kde.points", value = kde.points.fixed, ns = "ks",
##                   pos = 3)
## # ns = "ks" to indicate the package namespace, pos = 3 to indicate :::
## 
## # Check the result
## ks:::kde.points

## ---- kdde-1, fig.cap = '(ref:kdde-1-title)', fig.margin = FALSE---------
# Simulated univariate data
n <- 1e3
set.seed(324178)
x <- nor1mix::rnorMix(n = n, obj = nor1mix::MW.nm8)

# Location of relative extrema
dens <- function(x) nor1mix::dnorMix(x, obj = nor1mix::MW.nm8)
minus_dens <- function(x) -dens(x)
extrema <- c(nlm(f = minus_dens, p = 0)$estimate,
             nlm(f = dens, p = 0.75)$estimate,
             nlm(f = minus_dens, p = 1.5)$estimate)

# Plot target density
par(mfrow = c(2, 2))
plot(nor1mix::MW.nm8)
rug(x)
abline(v = extrema, col = c(3, 2, 3))

# Density estimation (automatically chosen bandwidth)
kdde_0 <- ks::kdde(x = x, deriv.order = 0)
plot(kdde_0, xlab = "x", main = "Density estimation")
abline(v = extrema, col = c(3, 2, 3))

# Density derivative estimation (automatically chosen bandwidth, but different
# from kdde_0!)
kdde_1 <- ks::kdde(x = x, deriv.order = 1)
plot(kdde_1, xlab = "x", main = "Density derivative estimation")
abline(v = extrema, col = c(3, 2, 3))

# Density second derivative estimation
kdde_2 <- ks::kdde(x = x, deriv.order = 2)
plot(kdde_2, xlab = "x", main = "Density second derivative estimation")
abline(v = extrema, col = c(3, 2, 3))

## ---- kdde-2-------------------------------------------------------------
# Simulated bivariate data
n <- 1e3
mu_1 <- rep(1, 2)
mu_2 <- rep(-1.5, 2)
Sigma_1 <- matrix(c(1, -0.75, -0.75, 3), nrow = 2, ncol = 2)
Sigma_2 <- matrix(c(2, 0.75, 0.75, 3), nrow = 2, ncol = 2)
w <- 0.45
set.seed(324178)
x <- ks::rmvnorm.mixt(n = n, mus = rbind(mu_1, mu_2),
                      Sigmas = rbind(Sigma_1, Sigma_2), props = c(w, 1 - w))

# Density estimation
kdde_0 <- ks::kdde(x = x, deriv.order = 0)
plot(kdde_0, display = "filled.contour2", xlab = "x", ylab = "y")

# Density derivative estimation
kdde_1 <- ks::kdde(x = x, deriv.order = 1)
str(kdde_1$estimate)
# $estimate is now a list of two matrices with each of the derivatives

# Plot of the gradient field - arrows pointing towards the modes
plot(kdde_1, display = "quiver", xlab = "x", ylab = "y")

# Plot of the two components of the gradient field
for(i in 1:2) {
  plot(kdde_1, display = "filled.contour2", which.deriv.ind = i,
       xlab = "x", ylab = "y")
}

# Second density derivative estimation
kdde_2 <- ks::kdde(x = x, deriv.order = 2)
str(kdde_2$estimate)
# $estimate is now a list of four matrices with each of the derivatives

# Plot of the two components of the gradient field ("which.deriv.ind" indicates
# the index in the Kronecker product)
par(mfcol = c(2, 2))
for(i in 1:4) {
  plot(kdde_2, display = "filled.contour2", which.deriv.ind = i,
       xlab = "x", ylab = "y")
}

## ---- bwd-pi, fig.margin = FALSE-----------------------------------------
# Simulated data
n <- 500
Sigma_1 <- matrix(c(1, -0.75, -0.75, 2), nrow = 2, ncol = 2)
Sigma_2 <- matrix(c(2, -0.25, -0.25, 1), nrow = 2, ncol = 2)
set.seed(123456)
samp <- ks::rmvnorm.mixt(n = n, mus = rbind(c(2, 2), c(-2, -2)),
                         Sigmas = rbind(Sigma_1, Sigma_2),
                         props = c(0.5, 0.5))

# Normal scale bandwidth
(Hns <- ks::Hns(x = samp))

# PI bandwidth unconstrained
(Hpi <- ks::Hpi(x = samp))

# PI bandwidth diagonal
(Hpi_diag <- ks::Hpi.diag(x = samp))

# Compare kdes
par(mfrow = c(2, 2))
cont <- seq(0, 0.05, l = 20)
col <- viridis::viridis
plot(ks::kde(x = samp, H = Hns), display = "filled.contour2",
     abs.cont = cont, col.fun = col, main = "NS")
plot(ks::kde(x = samp, H = diag(diag(Hns))), display = "filled.contour2",
     abs.cont = cont, col.fun = col, main = "NS diagonal")
plot(ks::kde(x = samp, H = Hpi), display = "filled.contour2",
     abs.cont = cont, col.fun = col, main = "PI")
plot(ks::kde(x = samp, H = Hpi_diag), display = "filled.contour2",
     abs.cont = cont, col.fun = col, main = "PI diagonal")

## ---- bwd-pi-der, fig.margin = FALSE-------------------------------------
# Normal scale bandwidth
(Hns <- ks::Hns(x = samp, deriv.order = 1))

# PI bandwidth unconstrained
(Hpi <- ks::Hpi(x = samp, deriv.order = 1))

# PI bandwidth diagonal
(Hpi_diag <- ks::Hpi.diag(x = samp, deriv.order = 1))

# Compare kddes
par(mfrow = c(2, 2))
cont <- seq(-0.02, 0.02, l = 21)
plot(ks::kdde(x = samp, H = Hns, deriv.order = 1),
     display = "filled.contour2", main = "NS", abs.cont = cont)
plot(ks::kdde(x = samp, H = diag(diag(Hns)), deriv.order = 1),
     display = "filled.contour2", main = "NS diagonal", abs.cont = cont)
plot(ks::kdde(x = samp, H = Hpi, deriv.order = 1),
     display = "filled.contour2", main = "PI", abs.cont = cont)
plot(ks::kdde(x = samp, H = Hpi_diag, deriv.order = 1),
     display = "filled.contour2", main = "PI diagonal", abs.cont = cont)

## ---- bwd-cv, fig.margin = FALSE-----------------------------------------
# LSCV bandwidth unsconstrained
Hlscv <- ks::Hlscv(x = samp)

# LSCV bandwidth diagonal
Hlscv_diag <- ks::Hlscv.diag(x = samp)

# BCV bandwidth unsconstrained
Hbcv <- ks::Hbcv(x = samp)

# BCV bandwidth diagonal
Hbcv_diag <- ks::Hbcv.diag(x = samp)

# Compare kdes
par(mfrow = c(2, 2))
cont <- seq(0, 0.03, l = 20)
col <- viridis::viridis
plot(ks::kde(x = samp, H = Hlscv), display = "filled.contour2",
     abs.cont = cont, col.fun = col, main = "LSCV")
plot(ks::kde(x = samp, H = Hlscv_diag), display = "filled.contour2",
     abs.cont = cont, col.fun = col, main = "LSCV diagonal")
plot(ks::kde(x = samp, H = Hbcv), display = "filled.contour2",
     abs.cont = cont, col.fun = col, main = "BCV")
plot(ks::kde(x = samp, H = Hbcv_diag), display = "filled.contour2",
     abs.cont = cont, col.fun = col, main = "BCV diagonal")

## ---- level-set-1, fig.cap = '(ref:level-set-1-title)'-------------------
# Simulated sample
n <- 100
set.seed(12345)
samp <- rnorm(n = n)

# Kde as usual, but force to evaluate it at seq(-4, 4, length = 4096)
bw <- bw.nrd(x = samp)
kde <- density(x = samp, bw = bw, n = 4096, from = -4, to = 4)

# For a given c, what is the theoretical level set? Since we know that the
# real density is symmetric and unimodal, then the level set is an inverval
# of the form [-x_c, x_c]
c <- 0.2
x_c <- tryCatch(uniroot(function(x) dnorm(x) - c, lower = 0, upper = 4)$root,
                error = function(e) NA)

# Show theoretical level set
x <- seq(-4, 4, by = 0.01)
plot(x, dnorm(x), type = "l", ylim = c(0, 0.5), ylab = "Density")
rug(samp)
polygon(x = c(-x_c, -x_c, x_c, x_c), y = c(0, c, c, 0),
        col = rgb(0, 0, 0, alpha = 0.5), density = 10)

# Function to compute and plot a kde level set. Observe that kde stands for an
# object containing the output of density(), although obvious modifications
# could be done to the function code could be done to receive a ks::kde object
# as the main argument
kde_level_set <- function(kde, c, add_plot = FALSE, ...) {

  # Begin and end index for the potantially many intervals in the level sets
  # of the kde
  kde_larger_c <- kde$y >= c
  run_length_kde <- rle(kde_larger_c) # Trick to compute the length of the
  # sequence of TRUEs that indicates an interval for which kde$y >= c
  begin <- which(diff(kde_larger_c) > 0) # Trick to search for the begin of
  # each of the intervals
  end <- begin + run_length_kde$lengths[run_length_kde$values] - 1 # Compute
  # the end of the intervals from begin + length

  # Add polygons to a density plot? If so, ... are the additional parameters
  # for polygon()
  if (add_plot) {

    apply(cbind(begin, end), 1, function(ind) {
      polygon(x = c(kde$x[ind[1]], kde$x[ind[1]],
                    kde$x[ind[2]], kde$x[ind[2]]),
              y = c(0, kde$y[ind[1]],
                    kde$y[ind[2]], 0), ...)
      })

  }

  # Return the [a_i, b_i], i = 1, ..., K in the K rows
  return(cbind(kde$x[begin], kde$x[end]))

}

# Add kde and level set
lines(kde, col = 2)
kde_level_set(kde = kde, c = c, add_plot = TRUE,
              col = rgb(1, 0, 0, alpha = 0.5))
abline(h = c, col = 4) # Level
legend("topright", legend = c("True density", "Kde", "True level set",
                              "Kde level set", "Level c"),
       lwd = 2, col = c(1, 2, rgb(0:1, 0, 0, alpha = 0.5), 4))

## ---- level-set-2, eval = FALSE------------------------------------------
## # Simulated sample
## n <- 100
## set.seed(12345)
## samp <- rnorm(n = n)
## 
## # Interactive visualization
## x <- seq(-4, 4, by = 0.01)
## manipulate::manipulate({
## 
##   # Show theoretical level set
##   plot(x, dnorm(x), type = "l", ylim = c(0, 0.5), ylab = "Density")
##   rug(samp)
##   x_c <- tryCatch(uniroot(function(x) dnorm(x) - c, lower = 0, upper = 4)$root,
##                   error = function(e) NA) # tryCatch() to bypass errors
##   polygon(x = c(-x_c, -x_c, x_c, x_c), y = c(0, c, c, 0),
##           col = rgb(0, 0, 0, alpha = 0.5), density = 10)
## 
##   # Add estimation
##   kde <- density(x = samp, bw = bw, n = 1e5, from = -4, to = 4)
##   lines(kde, col = 2)
##   kde_level_set(kde = kde, c = c, add_plot = TRUE,
##                 col = rgb(1, 0, 0, alpha = 0.5))
##   abline(h = c, col = 4) # Level
##   legend("topright", legend = c("True density", "Kde", "True level set",
##                                 "Kde level set", "Level c"),
##          lwd = 2, col = c(1, 2, rgb(0:1, 0, 0, alpha = 0.5), 4))
## 
## }, c = manipulate::slider(min = 0.01, max = 0.5, initial = 0.2, step = 0.01),
## bw = manipulate::slider(min = 0.01, max = 1, initial = 0.25, step = 0.01))

## ---- level-set-3, fig.cap = '(ref:level-set-3-title)'-------------------
# Simulate sample
n <- 200
set.seed(12345)
samp <- rnorm(n = n)

# We want to estimate the highest density region containing 0.75 probability
alpha <- 0.25

# For the N(0, 1), we know that this region is the interval [-x_c, x_c] with
x_c <- qnorm(1 - alpha / 2)
c_alpha <- dnorm(x_c)

# This corresponds to the c_alpha

# Theoretical level set
x <- seq(-4, 4, by = 0.01)
plot(x, dnorm(x), type = "l", ylim = c(0, 0.5), ylab = "Density")
rug(samp)
polygon(x = c(-x_c, -x_c, x_c, x_c), y = c(0, c_alpha, c_alpha, 0),
        col = rgb(0, 0, 0, alpha = 0.5), density = 10)
abline(h = c_alpha, col = 3, lty = 2) # Level

# Kde
bw <- bw.nrd(x = samp)
c_alpha_hat <- quantile(ks::kde(x = samp, h = bw, eval.points = samp)$estimate,
                        probs = alpha)
kde <- density(x = samp, bw = bw, n = 4096, from = -4, to = 4)
lines(kde, col = 2)
kde_level_set(kde = kde, c = c_alpha_hat, add_plot = TRUE,
              col = rgb(1, 0, 0, alpha = 0.5))
abline(h = c_alpha_hat, col = 4, lty = 2) # Level
legend("topright", legend = expression("True density", "Kde", "True level set",
                                       "Kde level set", "Level " * c[alpha],
                                       "Level " * hat(c)[alpha]),
       lwd = 2, col = c(1, 2, rgb(0:1, 0, 0, alpha = 0.5), 3:4),
       lty = c(rep(1, 4), rep(2, 4)))

## ---- level-set-4--------------------------------------------------------
# N(0, 1) case
alpha <- 0.3
x_c <- qnorm(1 - alpha / 2)
c_alpha <- dnorm(x_c)
c_alpha

# Approximates c_alpha
quantile(dnorm(samp), probs = alpha)

# True integral: 1 - alpha (by construction)
1 - 2 * pnorm(-x_c)

# Monte Carlo integration, approximates 1 - alpha
mean(dnorm(samp) >= c_alpha)

## ---- level-set-5--------------------------------------------------------
# Simulated sample from a mixture of normals
n <- 200
set.seed(123456)
mu <- c(2, 2)
Sigma1 <- diag(c(2, 2))
Sigma2 <- diag(c(1, 1))
samp <- rbind(mvtnorm::rmvnorm(n = n / 2, mean = mu, sigma = Sigma1),
              mvtnorm::rmvnorm(n = n / 2, mean = -mu, sigma = Sigma2))

# Level set of the true density at levels c
c <- c(0.01, 0.03)
x <- seq(-5, 5, by = 0.1)
xx <- as.matrix(expand.grid(x, x))
contour(x, x, 0.5 * matrix(mvtnorm::dmvnorm(xx, mean = mu, sigma = Sigma1) +
                             mvtnorm::dmvnorm(xx, mean = -mu, sigma = Sigma2),
                           nrow = length(x), ncol = length(x)),
        levels = c)

# Plot of the contour level
H <- ks::Hpi(x = samp)
kde <- ks::kde(x = samp, H = H)
plot(kde, display = "slice", abs.cont = c, add = TRUE, col = 4) # Argument
# "abs.cont" for specifying c rather than (1 - alpha) * 100 in "cont"
legend("topleft", lwd = 2, col = c(1, 4),
       legend = expression(L * "(" * f * ";" * c * ")",
                           L * "(" * hat(f) * "(" %.% ";" * H * "), " * c *")"))

# Computation of the probability cumulated in the level sets by numerical
# integration
ks::contourSizes(kde, abs.cont = c)

## ---- level-set-6a-------------------------------------------------------
# Simulate a sample from a mixture of normals
n <- 5e2
set.seed(123456)
mu <- c(2, 2, 2)
Sigma1 <- rbind(c(1, 0.5, 0.2),
                c(0.5, 1, 0.5),
                c(0.2, 0.5, 1))
Sigma2 <- rbind(c(1, 0.25, -0.5),
                c(0.25, 1, 0.5),
                c(-0.5, 0.5, 1))
samp <- rbind(mvtnorm::rmvnorm(n = n / 2, mean = mu, sigma = Sigma1),
              mvtnorm::rmvnorm(n = n / 2, mean = -mu, sigma = Sigma2))

# Plot of the contour level, changing the color palette
H <- ks::Hns(x = samp)
kde <- ks::kde(x = samp, H = H)
plot(kde, cont = 100 * c(0.99, 0.95, 0.5), col.fun = viridis::viridis,
     drawpoints = TRUE, col.pt = 1)
rgl::rglwidget()

## ---- level-set-6b-------------------------------------------------------
# Simulate a large sample from a single normal
n <- 5e4
set.seed(123456)
mu <- c(0, 0, 0)
Sigma <- rbind(c(1, 0.5, 0.2),
                c(0.5, 1, 0.5),
                c(0.2, 0.5, 1))
samp <- mvtnorm::rmvnorm(n = n, mean = mu, sigma = Sigma)

# Plot of the contour level
H <- ks::Hns(x = samp)
kde <- ks::kde(x = samp, H = H)
plot(kde, cont = 100 * c(0.75, 0.5, 0.25), xlim = c(-2.5, 2.5),
     ylim = c(-2.5, 2.5), zlim = c(-2.5, 2.5))
rgl::rglwidget()

## ---- level-set-7--------------------------------------------------------
# Compute kde of unicef dataset
data("unicef", package = "ks")
kde <- ks::kde(x = unicef)

# ks::ksupp evaluates whether the points in the grid spanned by ks::kde belong
# to the level set for alpha = 0.05 and then returns the points that belong to
# the level set
sup <- ks::ksupp(fhat = kde, cont = 95) # Effective support up to a 5% of data
plot(sup)

## ---- level-set-8--------------------------------------------------------
# The convex hull boundary of the level set can be computed with chull()
# It returns the indexes of the points passed that form the corners of the
# polygon of the convex hull
ch <- chull(sup)
plot(sup)
lines(sup[c(ch, ch[1]), ], col = 2, lwd = 2)
# One extra point for closing the polygon

## ---- level-set-9--------------------------------------------------------
# Compute the convex hull of sup via geometry::convhulln()
C <- geometry::convhulln(p = sup)
# The output of geometry::convhulln() is different from chull()

# The geometry::inhulln() allows to check if points are inside the convex hull
geometry::inhulln(ch = C, p = rbind(c(50, 50), c(150, 50)))

# The convex hull works as well in R^p. An example in which the level set is
# evaluated by Monte Carlo and then the convex hull of the points in the level
# set is computed

# Sample
set.seed(2134)
samp <- mvtnorm::rmvnorm(n = 1e2, mean = rep(0, 3))

# Evaluation sample: random data in [-3, 3]^3
M <- 1e3
eval_set <- matrix(runif(n = 3 * M, -3, 3), M, 3)

# Kde of samp, evaluated at eval_set
H <- ks::Hns.diag(samp)
kde <- ks::kde(x = samp, H = H, eval.points = eval_set)

# Convex hull of points in the level set for a given c
c <- 0.01
C <- geometry::convhulln(p = eval_set[kde$estimate > c, ])

# We can test if a new point belongs to the level set by just checking if it
# belongs to the convex hull, without the need of re-evaluating the kde, which
# is much more efficient
new_points <- rbind(c(1, 1, 1), c(2, 2, 2))
geometry::inhulln(ch = C, p = new_points)
ks::kde(x = samp, H = H, eval.points = new_points)$estimate > c

# # Performance evaluation
# microbenchmark::microbenchmark(
#   geometry::inhulln(ch = C, p = new_points),
#   ks::kde(x = samp, H = H, eval.points = new_points)$estimate > c)

## ---- ref:level-set-11---------------------------------------------------
alpha <- 0.4
p <- 2
c_alpha <- exp(-0.5 * qchisq(p = 1 - alpha, df = p)) /
  (sqrt(det(Sigma)) * (2 * pi)^(p / 2))

## ---- kmeans, echo = FALSE, fig.margin = FALSE, fig.cap = '(ref:kmeans-title)'----
# Data with 3 clusters
set.seed(23456789)
n <- 20
x <- rbind(matrix(rnorm(n, sd = 0.3), ncol = 2),
           cbind(rnorm(n, sd = 0.3), rnorm(n, mean = 2, sd = 0.3)),
           matrix(rnorm(n, mean = 1, sd = 0.3), ncol = 2))
colnames(x) <- c("x", "y")
par(mfrow = c(2, 2))
for (k in 1:4) {
  set.seed(23456789)
  cl <- kmeans(x, centers = k, nstart = 20)
  plot(x, col = cl$cluster, pch = 16, main = paste("k =", k))
  points(cl$centers, col = 1:k, pch = 8, cex = 2)
}

## ---- kmeans-claw, echo = FALSE, fig.cap = '(ref:kmeans-claw-title)'-----
set.seed(23456789)
n <- 1e3
x <- nor1mix::rnorMix(n = n, obj = nor1mix::MW.nm10)
cl <- kmeans(x, centers = 5, nstart = 20)
plot(nor1mix::MW.nm10, main = "")
points(x, rep(0, n), col = cl$cluster, pch = 15)

## ---- gravity, fig.cap = '(ref:gravity-title)'---------------------------
# Planets
th <- 2 * pi / 3
r <- 2
xi_1 <- r * c(cos(th + 0.5), sin(th + 0.5))
xi_2 <- r * c(cos(2 * th + 0.5), sin(2 * th + 0.5))
xi_3 <- r * c(cos(3 * th + 0.5), sin(3 * th + 0.5))

# Gravity force
gravity <- function(x) {

  (mvtnorm::dmvnorm(x = x, mean = xi_1, sigma = diag(rep(0.5, 2))) +
     mvtnorm::dmvnorm(x = x, mean = xi_2, sigma = diag(rep(0.5, 2))) +
     mvtnorm::dmvnorm(x = x, mean = xi_3, sigma = diag(rep(0.5, 2)))) / 3

}

# Compute numerically the gradient of an arbitrary function
attraction <- function(x) numDeriv::grad(func = gravity, x = x)

# Evaluate the vector field
x <- seq(-4, 4, l = 20)
xy <- expand.grid(x = x, y = x)
dir <- apply(xy, 1, attraction)

# Scale arrows to unit length for better visualization
len <- sqrt(colSums(dir^2))
dir <- 0.25 * scale(dir, center = FALSE, scale = len)

# Colors of the arrows according to their original magnitude
cuts <- cut(x = len, breaks = quantile(len, probs = seq(0, 1, length.out = 21)))
cols <- viridis::viridis(20)[cuts]

# Vector field plot
plot(0, 0, type = "n", xlim = c(-4, 4), ylim = c(-4, 4), xlab = "x", ylab = "y")
arrows(x0 = xy$x, y0 = xy$y, x1 = xy$x + dir[1, ], y1 = xy$y + dir[2, ],
       angle = 10, length = 0.1, col = cols, lwd = 2)
points(rbind(xi_1, xi_2, xi_3), pch = 19, cex = 1.5)

## ---- euler, fig.margin = FALSE, fig.cap = '(ref:euler-title)'-----------
# Mixture parameters
mu_1 <- rep(1, 2)
mu_2 <- rep(-1.5, 2)
Sigma_1 <- matrix(c(1, -0.75, -0.75, 3), nrow = 2, ncol = 2)
Sigma_2 <- matrix(c(2, 0.75, 0.75, 3), nrow = 2, ncol = 2)
Sigma_1_inv <- solve(Sigma_1)
Sigma_2_inv <- solve(Sigma_2)
w <- 0.45

# Density
f <- function(x) {
  w * mvtnorm::dmvnorm(x = x, mean = mu_1, sigma = Sigma_1) +
    (1 - w) * mvtnorm::dmvnorm(x = x, mean = mu_2, sigma = Sigma_2)
}

# Gradient (caution: only works adequately for x a vector, it is not vectorized;
# observe that in the Sigma_inv %*% (x - mu) part the substraction of mu and
# premultiplication by Sigma_inv are specific to a *single* point x)
Df <- function(x) {
  -(w * mvtnorm::dmvnorm(x = x, mean = mu_1, sigma = Sigma_1) *
      Sigma_1_inv %*% (x - mu_1) +
    (1 - w) * mvtnorm::dmvnorm(x = x, mean = mu_2, sigma = Sigma_2) *
      Sigma_2_inv %*% (x - mu_2))
}

# Plot density
ks::plotmixt(mus = rbind(mu_1, mu_2), Sigmas = rbind(Sigma_1, Sigma_2),
             props = c(w, 1 - w), display = "filled.contour2",
             gridsize = rep(251, 2), xlim = c(-5, 5), ylim = c(-5, 5),
             cont = seq(0, 90, by = 10), col.fun = viridis::viridis)

# Euler solution
x <- c(-2, 2)
# x <- c(-4, 0)
# x <- c(-4, 4)
N <- 1e3
h <- 0.5
phi <- matrix(nrow = N + 1, ncol = 2)
phi[1, ] <- x
for (t in 1:N) {

  phi[t + 1, ] <- phi[t, ] + h * Df(phi[t, ])# / f(phi[t, ])

}
lines(phi, type = "l")
points(rbind(x), pch = 19)
text(rbind(x), labels = "x", pos = 3)

# Mean of the components
points(rbind(mu_1, mu_2), pch = 16, col = 4)
text(rbind(mu_1, mu_2), labels = expression(mu[1], mu[2]), pos = 4, col = 4)

# The modes are different from the mean of the components! -- see the gradients
cbind(Df(mu_1), Df(mu_2))

# Modes
xi_1 <- optim(par = mu_1, fn = function(x) sum(Df(x)^2))$par
xi_2 <- optim(par = mu_2, fn = function(x) sum(Df(x)^2))$par
points(rbind(xi_1, xi_2), pch = 16, col = 2)
text(rbind(xi_1, xi_2), labels = expression(xi[1], xi[2]), col = 2, pos = 2)

## ---- kms-1--------------------------------------------------------------
# A simulated example for which the population clusters are known
# Extracted from ?ks::dmvnorm.mixt
mus <- rbind(c(-1, 0), c(1, 2 / sqrt(3)), c(1, -2 / sqrt(3)))
Sigmas <- 1/25 * rbind(ks::invvech(c(9, 63/10, 49/4)),
                       ks::invvech(c(9, 0, 49/4)),
                       ks::invvech(c(9, 0, 49/4)))
props <- c(3, 3, 1) / 7

# Sample the mixture
set.seed(123456)
x <- ks::rmvnorm.mixt(n = 1000, mus = mus, Sigmas = Sigmas, props = props)

# Kernel mean shift clustering. If H is not specified, then
# H = ks::Hpi(x, deriv.order = 1) is employed. Its computation may take some
# time, so it is advisable to compute it separately for later reusage
H <- ks::Hpi(x = x, deriv.order = 1)
kms <- ks::kms(x = x, H = H)

# Plot clusters
plot(kms, col = viridis::viridis(kms$nclust), pch = 19, xlab = "x", ylab = "y")

# Summary
summary(kms)

# Objects in the kms object
kms$nclust # Number of clusters found
kms$nclust.table # Sizes of clusters
kms$mode # Estimated modes

# With keep.path = TRUE the ascending paths are returned
kms <- ks::kms(x = x, H = H, keep.path = TRUE)
cols <- viridis::viridis(kms$nclust, alpha = 0.5)[kms$label]
plot(x, col = cols, pch = 19, xlab = "x", ylab = "y")
for (i in 1:nrow(x)) lines(kms$path[[i]], col = cols[i])
points(kms$mode, pch = 8, cex = 2, lwd = 2)

## ---- kms-2--------------------------------------------------------------
# Partition of the whole sample space
kms_part <- ks::kms.part(x = x, H = H, xmin = c(-3, -3), xmax = c(3, 4),
                         gridsize = c(150, 150))
plot(kms_part, display = "filled.contour2", col = viridis::viridis(kms$nclust),
     xlab = "x", ylab = "y")
points(kms_part$mode, pch = 8, cex = 2, lwd = 2)

# Partition of the population
mixt_part <- ks::mvnorm.mixt.part(mus = mus, Sigmas = Sigmas, props = props,
                                  xmin = c(-3, -3), xmax = c(3, 4),
                                  gridsize = c(150, 150))
plot(mixt_part, display = "filled.contour2", col = viridis::viridis(kms$nclust),
     xlab = "x", ylab = "y")

# Obtain the modes of a mixture of normals automatically
modes <- ks::mvnorm.mixt.mode(mus = mus, Sigmas = Sigmas, props = props)
points(modes, pch = 8, cex = 2, lwd = 2)
modes
mus

## ---- kms-3a-------------------------------------------------------------
# Obtain PI bandwidth
H <- ks::Hpi(x = iris[, 1:3], deriv.order = 1)

# Many (8) clusters: probably due to the repetitions in the data
kms_iris <- ks::kms(x = iris[, 1:3], H = H)
summary(kms_iris)

# Force to only find clusters that contain at least 10% of the data
# kms merges internally the small clusters with the closest ones
kms_iris <- ks::kms(x = iris[, 1:3], H = H, min.clust.size = 15)
summary(kms_iris)

# Pairs plot -- good match of clustering with Species
plot(kms_iris, pch = as.numeric(iris$Species) + 1,
     col = viridis::viridis(kms_iris$nclust))

## ---- kms-3b-------------------------------------------------------------
# See ascending paths
kms_iris <- ks::kms(x = iris[, 1:3], H = H, min.clust.size = 15,
                    keep.path = TRUE)
cols <- viridis::viridis(kms_iris$nclust)[kms_iris$label]
rgl::plot3d(kms_iris$x, col = cols)
for (i in 1:nrow(iris)) rgl::lines3d(kms_iris$path[[i]], col = cols[i])
rgl::spheres3d(kms_iris$mode, radius = 0.05)
rgl::rglwidget()

## ---- kda-1, fig.cap = '(ref:kda-1-title)'-------------------------------
# Univariate example
x <- iris$Sepal.Length
groups <- iris$Species

# By default, the ks::hpi bandwidths are computed
kda_1 <- ks::kda(x = x, x.group = groups)

# Manual specification of bandwidths via ks::hkda (we have univariate data)
hs <- ks::hkda(x = x, x.group = groups, bw = "plugin")
kda_1 <- ks::kda(x = x, x.group = groups, hs = hs)

# Estimated class probabilites
kda_1$prior.prob

# Classification
head(kda_1$x.group.estimate)

# Classification error
ks::compare(x.group = kda_1$x.group, est.group = kda_1$x.group.estimate)

# Classification regions (points on the bottom)
plot(kda_1, xlab = "Sepal length", drawpoints = TRUE, col = rainbow(3))
legend("topright", legend = c("Setosa", "Versicolor", "Virginica"),
       lwd = 2, col = rainbow(3))

## ---- kda-2, fig.cap = '(ref:kda-2-title)'-------------------------------
# Bivariate example
x <- iris[, 1:2]
groups <- iris$Species

# By default, the ks::Hpi bandwidths are computed
kda_2 <- ks::kda(x = x, x.group = groups)

# Manual specification of bandwidths via ks::Hkda
Hs <- ks::Hkda(x = x, x.group = groups, bw = "plugin")
kda_2 <- ks::kda(x = x, x.group = groups, Hs = Hs)

# Classification error
ks::compare(x.group = kda_2$x.group, est.group = kda_2$x.group.estimate)

# Plot of classification regions
plot(kda_2, col = rainbow(3), lwd = 2, col.pt = 1, cont = seq(5, 85, by = 20),
     col.part = rainbow(3, alpha = 0.25), drawpoints = TRUE)

## ---- kda-3--------------------------------------------------------------
# Trivariate example
x <- iris[, 1:3]
groups <- iris$Species

# Normal scale bandwidths to avoid undersmoothing
Hs <- rbind(ks::Hns(x = x[groups == "setosa", ]),
            ks::Hns(x = x[groups == "versicolor", ]),
            ks::Hns(x = x[groups == "virginica", ]))
kda_3 <- ks::kda(x = x, x.group = groups, Hs = Hs)

# Classification regions
plot(kda_3, drawpoints = TRUE, col.pt = c(2, 3, 4), cont = seq(5, 85, by = 20))
rgl::rglwidget()


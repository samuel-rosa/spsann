% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/optimMSSD.R
\name{optimMSSD}
\alias{optimMSSD}
\alias{objMSSD}
\alias{MSSD}
\title{Optimization of sample configurations for spatial interpolation (I)}
\usage{
optimMSSD(
  points,
  candi,
  eval.grid,
  schedule,
  plotit = FALSE,
  track = FALSE,
  boundary,
  progress = "txt",
  verbose = FALSE
)

objMSSD(points, candi, eval.grid)
}
\arguments{
\item{points}{Integer value, integer vector, data frame or matrix, or list.
\itemize{
\item Integer value. The sample size. The starting sample configuration will be randomly sampled from
\code{candi}.
\item Integer vector. The row indexes of \code{candi} that correspond to the samples that form the starting
sample configuration. The length of the vector defines the number of samples.
\item Data frame or matrix. An object with three columns in the following order: \verb{[, "id"]}, the row indexes
of \code{candi} that correspond to each sample, \verb{[, "x"]}, the projected x-coordinates, and \verb{[, "y"]},
the projected y-coordinates.
\item List. An object with two named sub-arguments: \code{fixed}, a data frame or matrix with the projected x-
and y-coordinates of the existing sample configuration -- kept fixed during the optimization --,
and \code{free}, an integer value defining the number of samples that should be added to the existing
sample configuration -- free to move during the optimization.
}}

\item{candi}{Data frame or matrix with the candidate locations for the jittered samples. \code{candi} must have
two columns in the following order: \verb{[, "x"]}, the projected x-coordinates, and \verb{[, "y"]}, the projected
y-coordinates.}

\item{eval.grid}{(Experimental) Data frame or matrix with the objective function evaluation locations. Like
\code{candi}, \code{eval.grid} must have two columns in the following order: \verb{[, "x"]}, the projected x-coordinates,
and \verb{[, "y"]}, the projected y-coordinates.}

\item{schedule}{List with named sub-arguments defining the control parameters of the cooling schedule.
See \verb{\link[spsann]\{scheduleSPSANN\}}.}

\item{plotit}{(Optional) Logical for plotting the optimization results, including a) the progress of the
objective function, and b) the starting (gray circles) and current sample configuration (black dots), and
the maximum jitter in the x- and y-coordinates. The plots are updated at each 10 jitters. When adding
samples to an existing sample configuration, fixed samples are indicated using black crosses. Defaults to
\code{plotit = FALSE}.}

\item{track}{(Optional) Logical value. Should the evolution of the energy state be recorded and returned
along with the result? If \code{track = FALSE} (the default), only the starting and ending energy states are
returned along with the results.}

\item{boundary}{(Optional) SpatialPolygon defining the boundary of the spatial domain. If missing and
\code{plotit = TRUE}, \code{boundary} is estimated from \code{candi}.}

\item{progress}{(Optional) Type of progress bar that should be used, with options \code{"txt"}, for a text
progress bar in the R console, \code{"tk"}, to put up a Tk progress bar widget, and \code{NULL} to omit the progress
bar. A Tk progress bar widget is useful when using parallel processors. Defaults to \code{progress = "txt"}.}

\item{verbose}{(Optional) Logical for printing messages about the progress of the optimization. Defaults to
\code{verbose = FALSE}.}
}
\value{
\code{optimMSSD} returns an object of class \code{OptimizedSampleConfiguration}: the optimized sample
configuration with details about the optimization.

\code{objMSSD} returns a numeric value: the energy state of the sample configuration -- the objective
function value in square map units, generally m^2 or km^2.
}
\description{
Optimize a sample configuration for spatial interpolation with a 'known' auto- or cross-correlation model,
e.g. simple and ordinary (co)kriging. The criterion used is the mean squared shortest distance (\strong{MSSD})
between sample locations and prediction locations.
}
\details{
\subsection{Generating mechanism}{
There are multiple mechanism to generate a new sample configuration out of an existing one. The main step
consists of randomly perturbing the coordinates of a single sample, a process known as \sQuote{jittering}.
These mechanisms can be classified based on how the set of candidate locations for the samples is defined.
For example, one could use an \emph{infinite} set of candidate locations, that is, any location in the spatial
domain can be selected as a new sample location after a sample is jittered. All that is needed is a
polygon indicating the boundary of the spatial domain. This method is more computationally demanding
because every time an existing sample is jittered, it is necessary to check if the new sample location
falls in spatial domain.

Another approach consists of using a \emph{finite} set of candidate locations for the samples. A finite set of
candidate locations is created by discretising the spatial domain, that is, creating a fine (regular) grid
of points that serve as candidate locations for the jittered sample. This is a less computationally
demanding jittering method because, by definition, the new sample location will always fall in the spatial
domain.

Using a finite set of candidate locations has two important inconveniences. First, not all locations in
the spatial domain can be selected as the new location for a jittered sample. Second, when a sample is
jittered, it may be that the new location already is occupied by another sample. If this happens, another
location has to be iteratively sought for, say, as many times as the size of the sample configuration. In
general, the larger the size of the sample configuration, the more likely it is that the new location
already is occupied by another sample. If a solution is not found in a reasonable time, the the sample
selected to be jittered is kept in its original location. Such a procedure clearly is suboptimal.

\strong{spsann} uses a more elegant method which is based on using a finite set of candidate locations coupled
with a form of \emph{two-stage random sampling} as implemented in the R-package
\code{[spsample](https://CRAN.R-project.org/package=spcosa)}. Because the candidate locations are placed on
a finite regular grid, they can be taken as the centre nodes of a finite set of grid cells (or pixels of a
raster image). In the first stage, one of the \dQuote{grid cells} is selected with replacement, i.e.
independently of already being occupied by another sample. The new location for the sample chosen to be
jittered is selected within that \dQuote{grid cell} by simple random sampling. This method guarantees that
virtually any location in the spatial domain can be selected. It also discards the need to check if the new
location already is occupied by another sample, speeding up the computations when compared to the first two
approaches.
}

\subsection{Annealing schedule}{
The \emph{search graph} corresponds to the set of effective candidate locations for a sample location selected to
be jittered. The size of the search graph, i.e. area within which a sample location can be moved around, is
related to the concept of \emph{temperature}. A larger search graph is equivalent to higher temperatures, which
potentially result in more movement -- or \sQuote{agitation} -- of the set of sample locations.

The current version of the \pkg{spsann}-package uses a linear cooling schedule which depends upon the number
of jitters to control the size of the search graph. The equations are

\eqn{x_max = x_max0 - (chains_i / chains) * (x_max0 - x_min) + x_cellsize + x_min0}

and

\eqn{y_max = y_max0 - (chains_i / chains) * (y_max0 - y_min) + y_cellsize + y_min0},

where $x_max0$ and $y_max0$ are the maximum allowed shifts in the x- and y-coordinates in the first chain,
$x_min$ and $y_min$ are the minimum required shifts in the x- and y-coordinates, $x_max$ and $y_max$ are
the maximum allowed shifts in the x- and y-coordinates during the next chain, $chains$ and $chain_i$ are
the total and current chains, and $x_cellsize$ and $y_cellsize$ are the grid spacing in the x- and
y-coordinates. Because $x_cellsize$ and $y_cellsize$ can be equal to zero when a finite set of candidate
locations is used, $x_min0$ and $y_min0$ are the maximum nearest neighbour distance in the x- and
y-coordinates between candidate locations.
}

\subsection{Mean squared shortest distance}{
This objective function is based on the knowledge that the simple and ordinary (co)kriging prediction error
variance only depends upon the separation distance between sample locations: the larger the distance, the
larger the prediction error variance. As such, the better the spread of the sample locations in the spatial
domain, the smaller the overall simple/ordinary (co)kriging prediction error variance. This is the purpose
of using a regular grid of sample locations.

However, a regular grid usually is suboptimal, especially if the spatial domain is irregularly shaped. Thus
the need for optimization, that is based on measuring the goodness of the spread of sample locations in the
spatial domain. To measure this spread we can compute the distance from every sample location to each of the
prediction locations placed on a fine grid covering the entire spatial domain. Next, for every prediction
location we find the closest sample location and record its distance. The mean of these squared distances
over all prediction location will measure the spread of the sample locations.

During the optimization, we try to reduce this measure -- the mean squared shortest distance -- between
sample and prediction locations. (This is also know as \emph{spatial coverage sampling}, see the R-package
\strong{\href{https://CRAN.R-project.org/package=spcosa}{spcosa}}.)
}
}
\note{
\subsection{Distance between two points}{
\strong{spsann} always computes the distance between two locations (points) as the
\href{https://en.wikipedia.org/wiki/Euclidean_distance}{Euclidean distance} between them. This computation
requires the optimization to operate in the two-dimensional Euclidean space, i.e. the coordinates of
the sample, candidate and evaluation locations must be planar coordinates, generally in metres or
kilometres. \strong{spsann} has no mechanism to check if the coordinates are planar: you are the sole responsible
for making sure that this requirement is attained.
}

\subsection{Sample configuration for spatial interpolation}{
A sample configuration optimized for spatial interpolation such as simple and ordinary (co)kriging is not
necessarily appropriate for estimating the parameters of the spatial autocorrelation model, i.e. the
parameters of the variogram model. See \code{\link[spsann]{optimPPL}} for more information on the
optimization of sample configurations for variogram identification and estimation.
}
}
\examples{
#####################################################################
# NOTE: The settings below are unlikely to meet your needs.         #
#####################################################################
data(meuse.grid, package = 'sp')
candi <- meuse.grid[, 1:2]
schedule <- scheduleSPSANN(
  chains = 1, initial.temperature = 5000000,
  x.max = 1540, y.max = 2060, x.min = 0, y.min = 0, cellsize = 40)
set.seed(2001)
res <- optimMSSD(points = 10, candi = candi, schedule = schedule)
data.frame(
  expected = 247204.8,
  objSPSANN = objSPSANN(res),
  objMSSD = objMSSD(candi = candi, points = res)
)

}
\references{
Brus, D. J.; de Gruijter, J. J.; van Groenigen, J.-W. Designing spatial coverage samples using the k-means
clustering algorithm. In: P. Lagacherie,A. M.; Voltz, M. (Eds.) \emph{Digital soil mapping -- an introductory
perspective}. Elsevier, v. 31, p. 183-192, 2006.

de Gruijter, J. J.; Brus, D.; Bierkens, M.; Knotters, M. \emph{Sampling for natural resource monitoring}.
Berlin: Springer, p. 332, 2006.

Walvoort, D. J. J.; Brus, D. J.; de Gruijter, J. J. An R package for spatial coverage sampling and random
sampling from compact geographical strata by k-means. \emph{Computers and Geosciences}. v. 36, p.
1261-1267, 2010.
}
\seealso{
\code{[distanceFromPoints](https://CRAN.R-project.org/package=raster)},
\code{[stratify](https://CRAN.R-project.org/package=spcosa)}.
}
\author{
Alessandro Samuel-Rosa \email{alessandrosamuelrosa@gmail.com}
}
\concept{simulated annealing}
\concept{spatial interpolation}
\keyword{iteration}
\keyword{optimize}
\keyword{spatial}

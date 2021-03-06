% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/legends.r
\name{guidebox_as_column}
\alias{guidebox_as_column}
\title{Guidebox as a column}
\usage{
guidebox_as_column(legend, which.legend = 1, add.title = TRUE)
}
\arguments{
\item{which.legend}{Integer, a legend can contain multiple guide-boxes (or vice versa?).
Use this argument to select which to use.}

\item{add.title}{Does nothing yet.}

\item{p}{A ggplot2 plot or the extracted legend. 
\emph{Do not} provide a \code{\link[ggplot2]{ggplotGrob}} as it is indistinguisble
from a legend.}
}
\value{
A \code{\link[gtable]{gtable}} with keys and labels reordered into 
  a single column and each pair of keys and labels in the same cell.
}
\description{
Takes a plot or legend and returns a single guide-box in a single column,
for embedding in e.g. tables.
}
\examples{
library(ggplot2)
library(dplyr)

p <- ggplot(diamonds, aes(x=x, y=y, colour=cut)) + geom_point()
guidebox_as_column(p)
p <- p + guides(colour=guide_legend(ncol=2, byrow=TRUE))
guidebox_as_column(p)
}
\seealso{
\code{\link{g_legend}}
}

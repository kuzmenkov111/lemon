#' splot! - Stefan's  plot library of tricks
#'
#' Just another ggplot2 extension.
#'
#' @section Functions for axis:
#'
#' See \code{\link{coord_capped_cart}} and \code{\link{coord_flex_cart}}.
#' The latter is a shorthand version of the former.
#' It automatically uses \code{\link{capped_horisontal}} and
#' \code{\link{capped_vertical}}, but both accepts these as well as
#' \code{\link{brackets_horisontal}} and \code{\link{brackets_vertical}}.
#'
#' @section Legends:
#'
#' \describe{
#'   \item{Extract legend}{\code{\link{g_legend}}}
#'   \item{Many plots, one legend}{\code{\link{grid_arrange_shared_legend}}}
#'   \item{Place legend exactly on plot}{\code{\link{reposition_legend}}}
#' }
#'
#' @section Facets:
#'
#' \code{\link{facet_rep_grid}} and \code{\link{facet_rep_wrap}} are extensions
#' to the wellknown \code{\link[ggplot2]{facet_grid}} and
#' \code{\link[ggplot2]{facet_wrap}} where axis lines and labels are drawn on
#' all panels.
#'
#' @section Extending knitr:
#'
#' We automatically load knitr's \code{\link[knitr]{knit_print}} for
#' data frames and dplyr tables to provide automatic pretty printing of
#' data frame using \code{\link[knitr]{kable}}.
#'
#' See \code{\link{knit_print.data.frame}}.
#'
#' @docType package
#' @name splot
#' @author Stefan McKinnon Edwards <sme@@iysik.com>
#' @import ggplot2
#' @source \url{https://github.com/stefanedwards/splot}
"_PACKAGE"

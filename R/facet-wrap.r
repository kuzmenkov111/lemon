#' @include ggplot2.r
NULL

#' @rdname facet_rep
#' @import ggplot2
#' @export
#' @examples
#' ggplot(mpg, aes(displ, hwy)) +
#'   geom_point() +
#'   facet_wrap(~class)
facet_rep_wrap <- function(..., repeat.tick.labels=FALSE) {
  f <- facet_wrap(...)
  params <- append(f$params, list(repeat.tick.labels=repeat.tick.labels))
  ggplot2::ggproto(NULL, FacetWrapRepeatLabels,
          shrink=f$shrink,
          params=params)
}


#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
#' @import ggplot2
#' @import gtable
FacetWrapRepeatLabels <- ggplot2::ggproto('FacetWrapRepeatLabels',
                                          `_inherit`=ggplot2::FacetWrap,
  draw_panels = function(panels, layout, x_scales, y_scales, ranges, coord, data, theme, params) {
    # If coord is non-cartesian and (x is free or y is free)
    # then throw error
    if ((!inherits(coord, "CoordCartesian")) && (params$free$x || params$free$y)) {
      stop("ggplot2 does not currently support free scales with a non-cartesian coord", call. = FALSE)
    }
    if (inherits(coord, "CoordFlip")) {
      if (params$free$x) {
        layout$SCALE_X <- seq_len(nrow(layout))
      } else {
        layout$SCALE_X <- 1L
      }
      if (params$free$y) {
        layout$SCALE_Y <- seq_len(nrow(layout))
      } else {
        layout$SCALE_Y <- 1L
      }
    }

    ncol <- max(layout$COL)
    nrow <- max(layout$ROW)
    n <- nrow(layout)
    panel_order <- order(layout$ROW, layout$COL)
    layout <- layout[panel_order, ]
    panels <- panels[panel_order]
    panel_pos <- ggplot2:::convertInd(layout$ROW, layout$COL, nrow)

    axes <- ggplot2:::render_axes(ranges, ranges, coord, theme, transpose = TRUE)

    labels_df <- layout[names(params$facets)]
    attr(labels_df, "facet") <- "wrap"
    strips <- ggplot2::render_strips(
      structure(labels_df, type = "rows"),
      structure(labels_df, type = "cols"),
      params$labeller, theme)

    # If user hasn't set aspect ratio, and we have fixed scales, then
    # ask the coordinate system if it wants to specify one
    aspect_ratio <- theme$aspect.ratio
    if (is.null(aspect_ratio) && !params$free$x && !params$free$y) {
      aspect_ratio <- coord$aspect(ranges[[1]])
    }

    if (is.null(aspect_ratio)) {
      aspect_ratio <- 1
      respect <- FALSE
    } else {
      respect <- TRUE
    }

    empty_table <- matrix(list(ggplot2::zeroGrob()), nrow = nrow, ncol = ncol)
    panel_table <- empty_table
    panel_table[panel_pos] <- panels
    empties <- apply(panel_table, c(1,2), function(x) ggplot2:::is.zero(x[[1]]))
    panel_table <- gtable_matrix("layout", panel_table,
     widths = unit(rep(1, ncol), "null"),
     heights = unit(rep(aspect_ratio, nrow), "null"), respect = respect, clip = "on", z = matrix(1, ncol = ncol, nrow = nrow))
    panel_table$layout$name <- paste0('panel-', rep(seq_len(ncol), nrow), '-', rep(seq_len(nrow), each = ncol))

    panel_table <- gtable::gtable_add_col_space(panel_table,
      theme$panel.spacing.x %||% theme$panel.spacing)
    panel_table <- gtable::gtable_add_row_space(panel_table,
      theme$panel.spacing.y %||% theme$panel.spacing)

    # Add axes
    axis_mat_x_top <- empty_table
    axis_mat_x_top[panel_pos] <- axes$x$top[layout$SCALE_X]
    axis_mat_x_bottom <- empty_table
    axis_mat_x_bottom[panel_pos] <- axes$x$bottom[layout$SCALE_X]
    axis_mat_y_left <- empty_table
    axis_mat_y_left[panel_pos] <- axes$y$left[layout$SCALE_Y]
    axis_mat_y_right <- empty_table
    axis_mat_y_right[panel_pos] <- axes$y$right[layout$SCALE_Y]
    #if (!params$free$x) {
    #  axis_mat_x_top[-1,]<- list(zeroGrob())
    #  axis_mat_x_bottom[-nrow,]<- list(zeroGrob())
    #}
    #if (!params$free$y) {
    #  axis_mat_y_left[, -1] <- list(zeroGrob())
    #  axis_mat_y_right[, -ncol] <- list(zeroGrob())
    #}
    if (!params$repeat.tick.labels) {
      axis_mat_x_top[-1,] <- lapply(axis_mat_x_top[-1,], remove_labels_from_axis)
      axis_mat_x_bottom[-nrow,] <- lapply(axis_mat_x_bottom[-nrow,], remove_labels_from_axis)
      axis_mat_y_left[,-1] <- lapply(axis_mat_y_left[,-1], remove_labels_from_axis)
      axis_mat_y_right[, -ncol] <- lapply(axis_mat_y_right[, -ncol], remove_labels_from_axis)
    }
    axis_height_top <- unit(apply(axis_mat_x_top, 1, max_height), "cm")
    axis_height_bottom <- unit(apply(axis_mat_x_bottom, 1, max_height), "cm")
    axis_width_left <- unit(apply(axis_mat_y_left, 2, max_width), "cm")
    axis_width_right <- unit(apply(axis_mat_y_right, 2, max_width), "cm")
    # Add back missing axes
    if (any(empties)) {
      first_row <- which(apply(empties, 1, any))[1] - 1
      first_col <- which(apply(empties, 2, any))[1] - 1
      row_panels <- which(layout$ROW == first_row & layout$COL > first_col)
      row_pos <- ggplot2:::convertInd(layout$ROW[row_panels], layout$COL[row_panels], nrow)
      row_axes <- axes$x$bottom[layout$SCALE_X[row_panels]]
      col_panels <- which(layout$ROW > first_row & layout$COL == first_col)
      col_pos <- ggplot2:::convertInd(layout$ROW[col_panels], layout$COL[col_panels], nrow)
      col_axes <- axes$y$right[layout$SCALE_Y[col_panels]]
      if (params$strip.position == "bottom" &&
          theme$strip.placement != "inside" &&
          any(!vapply(row_axes, is.zero, logical(length(row_axes))))) {
        warning("Suppressing axis rendering when strip.position = 'bottom' and strip.placement == 'outside'", call. = FALSE)
      } else {
        axis_mat_x_bottom[row_pos] <- row_axes
      }
      if (params$strip.position == "right" &&
          theme$strip.placement != "inside" &&
          any(!vapply(col_axes, is.zero, logical(length(col_axes))))) {
        warning("Suppressing axis rendering when strip.position = 'right' and strip.placement == 'outside'", call. = FALSE)
      } else {
        axis_mat_y_right[col_pos] <- col_axes
      }
    }
    panel_table <- ggplot2:::weave_tables_row(panel_table, axis_mat_x_top, -1, axis_height_top, "axis-t", 3)
    panel_table <- ggplot2:::weave_tables_row(panel_table, axis_mat_x_bottom, 0, axis_height_bottom, "axis-b", 3)
    panel_table <- ggplot2:::weave_tables_col(panel_table, axis_mat_y_left, -1, axis_width_left, "axis-l", 3)
    panel_table <- ggplot2:::weave_tables_col(panel_table, axis_mat_y_right, 0, axis_width_right, "axis-r", 3)

    strip_padding <- convertUnit(theme$strip.switch.pad.wrap, "cm")
    strip_name <- paste0("strip-", substr(params$strip.position, 1, 1))
    strip_mat <- empty_table
    strip_mat[panel_pos] <- unlist(unname(strips), recursive = FALSE)[[params$strip.position]]
    if (params$strip.position %in% c("top", "bottom")) {
      inside <- (theme$strip.placement.x %||% theme$strip.placement %||% "inside") == "inside"
      if (params$strip.position == "top") {
        placement <- if (inside) -1 else -2
        strip_pad <- axis_height_top
      } else {
        placement <- if (inside) 0 else 1
        strip_pad <- axis_height_bottom
      }
      strip_height <- unit(apply(strip_mat, 1, max_height), "cm")
      panel_table <- ggplot2:::weave_tables_row(panel_table, strip_mat, placement, strip_height, strip_name, 2, "on")
      if (!inside) {
        strip_pad[unclass(strip_pad) != 0] <- strip_padding
        panel_table <- ggplot2:::weave_tables_row(panel_table, row_shift = placement, row_height = strip_pad)
      }
    } else {
      inside <- (theme$strip.placement.y %||% theme$strip.placement %||% "inside") == "inside"
      if (params$strip.position == "left") {
        placement <- if (inside) -1 else -2
        strip_pad <- axis_width_left
      } else {
        placement <- if (inside) 0 else 1
        strip_pad <- axis_width_right
      }
      strip_pad[unclass(strip_pad) != 0] <- strip_padding
      strip_width <- unit(apply(strip_mat, 2, max_width), "cm")
      panel_table <- ggplot2:::weave_tables_col(panel_table, strip_mat, placement, strip_width, strip_name, 2, "on")
      if (!inside) {
        strip_pad[unclass(strip_pad) != 0] <- strip_padding
        panel_table <- ggplot2:::weave_tables_col(panel_table, col_shift = placement, col_width = strip_pad)
      }
    }
    panel_table
  }
)

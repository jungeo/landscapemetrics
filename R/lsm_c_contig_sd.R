#' CONTIG_SD (class level)
#'
#' @description Standard deviation of Contiguity index (Shape metric)
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers.
#' @param directions The number of directions in which patches should be connected: 4 (rook's case) or 8 (queen's case).
#'
#' @details
#' \deqn{CONTIG_{SD} =  sd(CONTIG[patch_{ij}])}
#'
#' where \eqn{CONTIG[patch_{ij}]} is the contiguity of each patch.
#'
#' CONTIG_SD is a 'Shape metric'. It summarises each class as the mean of each patch
#' belonging to class i. CONTIG_SD asses the spatial connectedness (contiguity) of
#' cells in patches. The metric coerces patch values to a value of 1 and the background
#' to NA. A nine cell focal filter matrix:
#'
#' ```
#' filter_matrix <- matrix(c(1, 2, 1,
#'                           2, 1, 2,
#'                           1, 2, 1), 3, 3, byrow = T)
#' ```
#' ... is then used to weight orthogonally contiguous pixels more heavily than
#' diagonally contiguous pixels. Therefore, larger and more connections between
#' patch cells in the rookie case result in larger contiguity index values.
#'
#' \subsection{Units}{None}
#' \subsection{Range}{CONTIG_CV >= 0}
#' \subsection{Behaviour}{CONTIG_SD = 0 if the contiguity index is
#' identical for all patches. Increases, without limit, as the variation of
#' CONTIG increases.}
#'
#' @seealso
#' \code{\link{lsm_p_contig}},
#' \code{\link{lsm_c_contig_mn}},
#' \code{\link{lsm_c_contig_cv}}, \cr
#' \code{\link{lsm_l_contig_mn}},
#' \code{\link{lsm_l_contig_sd}},
#' \code{\link{lsm_l_contig_cv}}
#'
#' @return tibble
#'
#' @examples
#' lsm_c_contig_sd(landscape)
#'
#' @aliases lsm_c_contig_sd
#' @rdname lsm_c_contig_sd
#'
#' @references
#' McGarigal, K., SA Cushman, and E Ene. 2012. FRAGSTATS v4: Spatial Pattern Analysis
#' Program for Categorical and Continuous Maps. Computer software program produced by
#' the authors at the University of Massachusetts, Amherst. Available at the following
#' web site: http://www.umass.edu/landeco/research/fragstats/fragstats.html
#'
#' LaGro, J. 1991. Assessing patch shape in landscape mosaics.
#' Photogrammetric Engineering and Remote Sensing, 57(3), 285-293
#'
#' @export
lsm_c_contig_sd <- function(landscape, directions) UseMethod("lsm_c_contig_sd")

#' @name lsm_c_contig_sd
#' @export
lsm_c_contig_sd.RasterLayer <- function(landscape, directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_contig_sd_calc,
                     directions = directions)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_c_contig_sd
#' @export
lsm_c_contig_sd.RasterStack <- function(landscape, directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_contig_sd_calc,
                     directions = directions)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_c_contig_sd
#' @export
lsm_c_contig_sd.RasterBrick <- function(landscape, directions = 8) {

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_contig_sd_calc,
                     directions = directions)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_c_contig_sd
#' @export
lsm_c_contig_sd.stars <- function(landscape, directions = 8) {

    landscape <- methods::as(landscape, "Raster")

    result <- lapply(X = raster::as.list(landscape),
                     FUN = lsm_c_contig_sd_calc,
                     directions = directions)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

#' @name lsm_c_contig_sd
#' @export
lsm_c_contig_sd.list <- function(landscape, directions = 8) {

    result <- lapply(X = landscape,
                     FUN = lsm_c_contig_sd_calc,
                     directions = directions)

    layer <- rep(seq_len(length(result)),
                 vapply(result, nrow, FUN.VALUE = integer(1)))

    result <- do.call(rbind, result)

    tibble::add_column(result, layer, .before = TRUE)
}

lsm_c_contig_sd_calc <- function(landscape, directions) {

    contig <- lsm_p_contig_calc(landscape, directions = directions)

    contig_sd <- stats::aggregate(x = contig[, 5], by = contig[, 2],
                                  FUN = stats::sd)

    tibble::tibble(
        level = "class",
        class = as.integer(contig_sd$class),
        id = as.integer(NA),
        metric = "contig_sd",
        value = as.double(contig_sd$value)
    )
}

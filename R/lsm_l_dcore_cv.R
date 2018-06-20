#' Number of core areas distribution (landscape level)
#'
#' @description Coeffiecent of variation of number of core areas (landscape level)
#'
#' @param landscape Raster* Layer, Stack, Brick or a list of rasterLayers.
#'
#' @details
#' Equals the coeffiecent of variation of number of core area of all patches in the landscape.
#' A core area is a 'patch within the patch' without any edge cells. In other words,
#' the number of patches within the patch that only have neighbouring cells of the same type
#' \deqn{dcore_CV = cv(dcore[patch])}
#' \subsection{Units}{None}
#' \subsection{Range}{???}
#' \subsection{Behaviour}{???}
#'
#' @return tibble
#'
#' @examples
#' lsm_l_dcore_cv(landscape)
#'
#' @aliases lsm_l_dcore_cv
#' @rdname lsm_l_dcore_cv
#'
#' @references
#' McGarigal, K., and B. J. Marks. 1995. FRAGSTATS: spatial pattern analysis
#' program for quantifying landscape structure. USDA For. Serv. Gen. Tech. Rep.
#'  PNW-351.
#'
#' @export
lsm_l_dcore_cv <- function(landscape) UseMethod("lsm_l_dcore_cv")

#' @name lsm_l_dcore_cv
#' @export
lsm_l_dcore_cv.RasterLayer <- function(landscape) {
    purrr::map_dfr(raster::as.list(landscape), lsm_l_dcore_cv_calc, .id = "layer") %>%
        dplyr::mutate(layer = as.integer(layer))
}

#' @name lsm_l_dcore_cv
#' @export
lsm_l_dcore_cv.RasterStack <- function(landscape) {
    purrr::map_dfr(raster::as.list(landscape), lsm_l_dcore_cv_calc, .id = "layer") %>%
        dplyr::mutate(layer = as.integer(layer))
}

#' @name lsm_l_dcore_cv
#' @export
lsm_l_dcore_cv.RasterBrick <- function(landscape) {
    purrr::map_dfr(raster::as.list(landscape), lsm_l_dcore_cv_calc, .id = "layer") %>%
        dplyr::mutate(layer = as.integer(layer))
}

#' @name lsm_l_dcore_cv
#' @export
lsm_l_dcore_cv.list <- function(landscape) {
    purrr::map_dfr(landscape, lsm_l_dcore_cv_calc, .id = "layer") %>%
        dplyr::mutate(layer = as.integer(layer))

}

lsm_l_dcore_cv_calc <- function(landscape){

    dcore_cv <- landscape %>%
        lsm_p_ncore_calc() %>%
        dplyr::summarise(value = raster::cv(value, na.rm = TRUE))

    tibble::tibble(
        level = "landscape",
        class = as.integer(NA),
        id = as.integer(NA),
        metric = "number of core areas (cv)",
        value = dcore_cv$value
    )
}
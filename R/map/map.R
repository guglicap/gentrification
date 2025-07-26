#' Processes raw limcom data to build a map of polygons at the municipal level
#'
#' @param raw Raw data with municipal polygons
map_build_mun <- function(raw_mun) {
    read_sf(raw_mun) |>
        rmapshaper::ms_simplify(keep = 0.05) |>
        mutate(
            nome_com = str_standardize(nome_com),
            mun_code = as.double(istat)
        ) |>
        select(
            nome_com,
            mun_code
        ) |>
        relocate(
            mun = nome_com,
            mun_code
        ) |>
        mutate(
            year = 2020,
        ) |>
        st_transform("EPSG:3035")
}

#' Binds municipal map with submunicipal map, assigns IDs
#' @param map_mun sf object being a municipal level map
#' @param submun_poly_list named list of bindable objects containing polygons for submunicipalities e.g. list(MILANO = <sf>)
#'
#' @return sf object with the combined map, referred to as master_grid usually
map_build_master_grid <- function(map_mun, submun_poly_list = list()) {
    map_mun |>
        mutate(
            mun = str_standardize(mun),
        ) |>
        relocate(mun, mun_code)
}

map_write_master_grid <- function(master_grid, path = "export/master_grid.gpkg") {
    master_grid |> sf::st_write(
        dsn = path,
        delete_dsn = TRUE, layer = "master_grid"
    )
    return(path)
}

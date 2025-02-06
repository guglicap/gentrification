#' Processes raw limcom data to build a map of polygons at the municipal level
#'
#' @param raw Raw data with municipal polygons
map_build_mun <- function(raw_mun) {
    read_sf(raw_mun) |>
        rmapshaper::ms_simplify(keep = 0.05) |>
        select(nome_com, sig_pro) |>
        mutate(nome_com = str_standardize(nome_com), zip = NA) |>
        relocate(
            mun = nome_com,
            prov = sig_pro
        ) |>
        st_transform("EPSG:3035")
}

#' Compute polygons with voronoi tesselation and return them
#' in the same order as the points
#'
#' @param points The centroids for Voronoi tesselation
#'
#' @return A vector of polygons, computed from the input points, in the same order as the input
map_st_voronoi_point <- function(points) {
    if (!all(st_geometry_type(points) == "POINT")) {
        stop("Input not  POINT geometries")
    }
    g <- st_combine(st_geometry(points)) # crea oggetto multipoint per voronoi
    v <- st_voronoi(g)
    # estrai singole feature da collection
    v <- st_collection_extract(v)
    # ripristina ordine (ordine dei poligoni ora è lo stesso dei punti)
    return(v[unlist(st_intersects(points, v))])
}

#' Extracts polygon for a given municipality
#' @param map_mun sf object with municipalities' polygons
#' @param mun the municipality to extract
#'
#' @return an sf object containing only polygons mapping to mun
map_extract_mun_poly <- function(map_mun, extract_mun) {
    map_mun |> filter(mun == extract_mun)
}

map_generate_milan_submun <- function(raw_mi_submun, outline_mi) {
    read_sf(raw_mi_submun) |>
        select(zip = CAP, geometry) |>
        mutate(mun = "MILANO", prov = "MI") |>
        st_transform("EPSG:3035") |>
        st_intersection(outline_mi) |>
        select(mun, zip, prov)
}

#' Generates sunmunicipal polygons from Voronoi tesselation
#' @param mun municipality to generate submunicipal polygons for
#' @param prov province of municipality
#' @param points file readable by sf::read_sf with centroids for polygons generation
#' @param outline bounds for tesselation, usually municipality polygon
#'
#' @example generate_submun_poly("MILANO", "MI", pointcaps, mi_outline)
map_generate_submun_poly <- function(mun, prov, points, outline) {
    read_sf(points) |>
        filter(LAU_NAT == mun) |>
        st_transform("EPSG:3035") |>
        (\(.) st_set_geometry(., map_st_voronoi_point(points = .)))() |>
        select(zip = POSTCODE) |>
        mutate(
            mun = mun,
            prov = prov
        ) |>
        st_intersection(outline) |>
        select(mun, zip, prov, geometry)
}

#' Binds municipal map with submunicipal map, assigns IDs
#' @param map_mun sf object being a municipal level map
#' @param submun_poly_list named list of bindable objects containing polygons for submunicipalities e.g. list(MILANO = <sf>)
#' 
#' @return sf object with the combined map, referred to as master_grid usually
map_build_master_grid <- function(map_mun, submun_poly_list = list()) {
    settings <- sqids::sqids_options(
        min_length = 4
    )
    map_mun |>
        mutate(
            mun = str_standardize(mun),
            .rn = row_number()
        ) |>
        rowwise() |>
        mutate(geom_id = sqids::encode(.rn, settings)) |>
        ungroup() |>
        select(-.rn) |>
        relocate(mun, prov, geom_id)

    # TODO: implement submunicipal binding
}

map_write_master_grid <- function(master_grid, path = "export/master_grid.gpkg") {
    master_grid |> sf::st_write(
        dsn = path,
        delete_dsn = TRUE, layer = "master_grid"
    )
    return(path)
}

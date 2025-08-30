map_select_mun_neighborhood <- function(
    df,
    target_mun,
    limit = 64,
    max_distance_km = NA
    ) {
    centroid <- df |>
        dplyr::filter(mun == target_mun) |>
        sf::st_union() |>
        sf::st_geometry() |>
        sf::st_centroid() |>
        dplyr::first()
    dist <- df |>
        dplyr::mutate(
            dist = sf::st_distance(geom, centroid) |> units::set_units(km) |> as.numeric()
        )
    if (!is.na(max_distance_km)) {
        return(
            dist |> dplyr::filter(dist <= max_distance_km)
        )
    }
    dist |>
        slice_min(dist, n = limit) |>
        arrange(dist)
}

map_join <- function(data, map = master_grid) {
    dplyr::left_join(
        data,
        map
        |> dplyr::select(geom_id),
        by = "geom_id"
    ) |>
        sf::st_sf()
}

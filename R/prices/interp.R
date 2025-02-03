prices_extract_zones <- function(prices_tidied) {
    prices_tidied |>
        tibble() |>
        select(omi_mun_code, omi_zone, year, geometry) |>
        distinct() |>
        st_sf()
}

prices_intersect <- function(prices_zones, master_grid) {
    st_intersection(prices_zones, master_grid)
}

prices_intersect_pop <- function(prices_intersect, raw_census_path) {
    box::use(areal[aw_interpolate])
    census_raw <- read_sf(raw_census_path) |> select(
        GRD_ID,
        starts_with("TOT_P")
    )
    prices_intersect |>
        mutate(tid = str_glue("{omi_mun_code}_{omi_zone}_{year}")) |>
        aw_interpolate(
            source = census_raw,
            tid = tid,
            sid = GRD_ID,
            extensive = "TOT_P_2021"
        ) |>
        tibble() |>
        select(-geometry, -tid)
}

prices_interpolate <- function(prices_intersected_pop, prices_tidied) {
    inner_join(
        prices_intersected_pop,
        st_drop_geometry(prices_tidied) |> select(-mun),
        by = join_by(omi_mun_code, omi_zone, year)
    ) |>
        group_by(
            mun, zip, prov, year, geom_id,
            property_type, property_status, contract_type
        ) |>
        summarise(
            property_avg_price =
                sum(property_avg_price * TOT_P_2021, na.rm = TRUE) / sum(TOT_P_2021, na.rm = TRUE)
        ) |>
        ungroup() |>
        filter(
            !is.na(contract_type), !is.na(property_type), !is.na(property_status)
        )
}

prices_raw_files <-
    list(
        tar_target(
            prices_raw_folder,
            "data/omi",
            format = "file"
        )
    )

prices_targets <- list(
    tar_target(
        prices_years,
        prices_get_years(prices_raw_folder)
    ),
    tar_target(
        prices_raw,
        prices_load(prices_years),
        pattern = map(prices_years)
    ),
    tar_target(
        prices_tidied,
        prices_tidy(prices_raw),
        pattern = map(prices_raw)
    ),
    tar_target(
        prices_zones,
        prices_extract_zones(prices_tidied),
        pattern = map(prices_tidied)
    ),
    tar_target(
        prices_intersected,
        prices_intersect(prices_zones, master_grid),
        pattern = map(prices_zones)
    ),
    tar_target(
        prices_intersected_pop,
        prices_intersect_pop(prices_intersected, raw_census_path),
        pattern = map(prices_intersected)
    ),
    tar_target(
        prices_interpolated,
        prices_interpolate(prices_intersected_pop, prices_tidied),
        pattern = map(prices_intersected_pop, prices_tidied)
    ),
    tar_target(
        export_prices,
        command = {
            path <- "export/property_prices.csv"
            prices_interpolated |>
                arrange(mun, zip) |>
                write_csv(
                    path
                )
            path
        },
        format = "file"
    ),
    tar_target(
        prices_interpolated_plots_version,
        command = {
            prices_interpolated |>
                filter(
                    property_type %in% c(
                        "Abitazioni_civili", "Ville_e_Villini", "Negozi"
                    ),
                    property_status == "NORMALE"
                ) |>
                dplyr::select(-property_status) |>
                dplyr::mutate(
                    property_type = stringr::str_replace_all(
                        property_type,
                        "Abitazioni_civili",
                        "Apartments"
                    )
                ) |>
                dplyr::mutate(
                    property_type = stringr::str_replace_all(
                        property_type,
                        "Ville_e_Villini",
                        "Houses"
                    )
                ) |>
                dplyr::mutate(
                    property_type = stringr::str_replace_all(
                        property_type,
                        "Negozi",
                        "Stores"
                    )
                ) |>
                dplyr::mutate(
                    contract_type = stringr::str_to_sentence(contract_type)
                )
        }
    ),
    tar_target(
        prices_10y_delta,
        command = {
            prices_interpolated_plots_version |>
                filter(year %in% c(2011, 2021)) |>
                arrange(year) |>
                group_by(mun, zip, prov, geom_id, property_type, contract_type) |>
                reframe(property_price_delta = diff(property_avg_price) / property_avg_price[[1]]) |>
                right_join(master_grid, by = join_by(mun, zip, prov, geom_id))
        }
    )
)

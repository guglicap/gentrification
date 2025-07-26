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
        prices_mun,
        prices_aggregate_mun(prices_tidied, map_geom_ids),
        pattern = map(prices_tidied)
    ),
    tar_target(
        export_prices,
        command = {
            path <- "export/property_prices.csv"
            prices_mun |>
                arrange(mun, year) |>
                write_csv(
                    path
                )
            path
        },
        format = "file"
    )
)

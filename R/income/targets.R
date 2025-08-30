income_raw_files <- list(
    tar_target(raw_income_folder,
        "data/Redditi",
        format = "file"
    )
)

income_targets <- list(
    tar_target(
        income_raw,
        income_load(income_years, income_merge_list, income_rename_list),
        pattern = map(income_years)
    ),
    tar_target(
        income_submunicipal_mun_list,
        command = {
            income_raw |>
                filter(!is.na(zip)) |>
                distinct(mun) |>
                pull(mun)
        }
    ),
    tar_target(income_georef,
        command = {
            income_raw |>
                left_join(map_geom_ids, by = join_by(mun, prov, zip))
        },
        pattern = map(income_raw)
    ),
    tar_target(
        income_tidyfreqs,
        income_tidy_frequencies(income_georef),
        pattern = map(income_georef)
    )
)

income_targets <- c(income_targets, income_params)

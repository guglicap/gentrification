income_raw_files <- list(
    tar_target(raw_income_folder,
        "data/Redditi",
        format = "file"
    )
)

income_targets <- list(
    tar_target(
        income_years,
        income_get_years(raw_income_folder),
    ),
    tar_target(
        income_raw,
        income_load(income_years, master_grid),
        pattern = map(income_years)
    ),
    tar_target(
        income_tidyfreqs,
        income_tidy_frequencies(income_raw),
        pattern = map(income_raw)
    ),
    tar_target(
        income_bins_cutoff,
        command = {
            c(0.5, 0.9)
        }
    ),
    tar_target(
        income_percentile_pop,
        income_calc_percentile_population(income_tidyfreqs, income_bins_cutoff),
        pattern = map(income_tidyfreqs)
    ),
    tar_target(
        export_percentile_pop,
        command = {
            path <- file.path("export", "percentile_pop.csv")
            readr::write_csv(income_percentile_pop, path)
            path
        },
        format = "file"
    ),
    tar_target(
        income_10y_percentile_delta,
        command = {
            income_percentile_pop |>
                group_by(mun, zip, geom_id, percentile_bin) |>
                filter(year %in% c(2021, 2011)) |>
                arrange(year) |>
                reframe(delta_bin_pop = diff(bin_pop))
        }
    )
)

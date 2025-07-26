incpoprent_targets <- list(
    tar_target(
        incpoprent,
        command = {
            income_median <- income_mun_median |>
                # filter(year == 2011) |>
                select(-mun)
            income_pcnt <- income_percentile_pop |>
                # filter(year == 2011) |>
                pivot_wider(
                    names_from = "percentile_bin",
                    values_from = "bin_pop",
                    id_cols = c("mun_code", "year")
                )
            prices <- prices_mun |>
                # filter(year == 2011) |>
                # select() |>
                filter(!if_any(everything(), is.na))
            census <- census_agetotal_tidied |>
                # filter(year == 2011) |>
                filter(!str_starts(ITTER107, "IT")) |>
                mutate(mun_code = as.double(ITTER107)) |>
                select(-ITTER107, -ETA1, -Territorio) |>
                rename(year = TIME)
            full_join(
                income_median,
                income_pcnt,
                by = join_by(mun_code, year)
            ) |>
                full_join(
                    prices,
                    by = join_by(mun_code, year)
                ) |>
            full_join(
            census,
            by = join_by(mun_code, year)
            )
        }
    )
)

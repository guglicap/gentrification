dynmodels_vars <- tidyr::expand_grid(
    cities = c("MILANO", "ROMA", "NAPOLI"),
    years = c(2011, 2015, 2021)
)

dynmodels_targets <- list(
    tar_map(
        values = dynmodels_vars,
        names = cities,
        tar_target(
            dynmodels_neighborhood,
            command = {
                neighborhood <- master_grid |>
                    map_select_mun_neighborhood(
                        cities,
                        max_distance_km = dynmodels_neighborhood_radius
                    )
            }
        ),
        tar_target(
            dynmodels_agent_dist,
            command = {
                freq <- income_tidyfreqs |>
                    dplyr::filter(
                        year == years,
                        geom_id %in% dynmodels_neighborhood$geom_id
                    )
                pop <- freq |>
                    group_by(year, geom_id) |>
                    income_calc_n_contribs() |>
                    ungroup()
                freq <- freq |>
                    income_calc_percentile_population(dynmodels_bins_cutoff)
                levels(freq$percentile_bin) <- c("L", "M", "H")
                freq |>
                    left_join(pop, by = join_by(year, geom_id)) |>
                    left_join(dynmodels_neighborhood, by = join_by(geom_id)) |>
                    mutate(
                        agent_pop = round(bin_pop * n_contribs)
                    ) |>
                    select(geom_id, year, pop = agent_pop, cl = percentile_bin)
                    # pivot_wider(
                        # names_from = "cl",
                        # values_from = "P_cl"
                    # )
            }
        ),
        tar_target(
            dynmodels_export,
            command = {
                ROOT_DIR <- "export/sim"
                dir.create(ROOT_DIR, showWarnings = FALSE, recursive = TRUE)
                agent_file <- paste0("class_distribution_", cities, "_", years, ".csv")
                path <- file.path(ROOT_DIR, agent_file)
                write_csv(
                    dynmodels_agent_dist,
                    path
                )
                path
            },
            format = "file"
        )
    )
)

dynmodels_targets <- c(dynmodels_params, dynmodels_targets)

dynmodels_vars <- tidyr::expand_grid(
    cities = c("MILANO"),
    years = c(2011, 2021)
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
                        limit = dynmodels_grid_w * dynmodels_grid_h
                    ) |>
                    mutate(
                        k = row_number() - 1,
                    ) |>
                    mutate(
                        i = k %% dynmodels_grid_w,
                        j = floor(as.double(k) / as.double(dynmodels_grid_h))
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
                    mutate(percent_contribs = n_contribs / sum(n_contribs)) |>
                    ungroup()
                freq <- freq |>
                    income_calc_percentile_population(dynmodels_bins_cutoff) |>
                    left_join(pop, by = join_by(year, geom_id)) |>
                    left_join(dynmodels_neighborhood, by = join_by(geom_id)) |>
                    select(i, j, geom_id, year,
                        cell_percent_of_total_agents = percent_contribs,
                        percent_of_agent_type = bin_pop,
                        agent_type = percentile_bin
                    ) |>
                    mutate(
                        likelyhood = percent_of_agent_type * cell_percent_of_total_agents
                    )
                levels(freq$agent_type) <- c("C", "B", "A")
                freq
            }
        ),
        tar_target(
            dynmodels_export,
            command = {
                ROOT_DIR <- "export"
                agent_file <- paste0("dynmodels_agent_dist_", years, "_", cities, ".csv")
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

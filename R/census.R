census_raw_files <- list(
    tar_target(raw_census_path, "data/census.gpkg", format = "file")
)

census_targets <- list(
    tar_target(
        census_interpolated,
        census_interpolate(master_grid, raw_census_path)
    ),
    tar_target(
        export_census,
        census_write(census_interpolated),
        format = "file"
    ),
    tar_target(
        census_10y_delta,
        command = {
            census_interpolated |>
                pivot_wider(
                    values_from = "population",
                    names_from = "year",
                    names_prefix = "pop_"
                ) |>
                group_by(mun, zip, prov, geom_id) |>
                summarise(pop_delta_rel = (pop_2021 - pop_2011) / pop_2011)
        }
    ),
    tar_target(
        census_ranked,
        command = {
            census_interpolated |>
                group_by(year, mun) |>
                summarise(population = sum(population, na.rm = TRUE)) |>
                mutate(rank = rank(-population)) |>
                ungroup()
        }
    ),
    tar_target(
        census_rankdelta,
        command = {
            census_ranked |>
                arrange(year) |>
                group_by(mun) |>
                filter(n() == 2) |>
                mutate(rank_delta = diff(rank)) |>
                filter(year == 2011) |>
                select(-year) |>
                rename(pop_2011 = population) |>
                ungroup() |>
                mutate(pop_2011 = log10(pop_2011))
        }
    )
)

#' Interpolate census data from Eurostat GISCO grid over master_grid
#' @param master_grid master-grid object (sf)
#' @param raw_census GISCO grid file path
#'
#' @return an sf object with population estimates for years 2011 and 2021 referenced to the master-grid
census_interpolate <- function(master_grid, raw_census_path) {
    census <- read_sf(raw_census_path) |>
        select(
            GRD_ID,
            starts_with("TOT_P")
        )
    master_grid <- master_grid |>
        mutate(
            ID = paste(mun, zip)
        )
    interpolated <- aw_interpolate(
        master_grid,
        tid = ID,
        source = census,
        sid = GRD_ID,
        extensive = c(
            "TOT_P_2011",
            "TOT_P_2021"
        )
    ) |>
        select(-ID)

    pivoted <- interpolated |>
        pivot_longer(
            cols = starts_with("TOT_P"),
            names_to = "year",
            names_prefix = "TOT_P_",
            values_to = "population"
        ) |>
        mutate(
            year = as.numeric(year),
            population = round(population)
        )

    pivoted
}

census_write <- function(census_interpolated, to = "export/census.gpkg") {
    census_interpolated |> sf::st_write(
        dsn = to,
        delete_dsn = TRUE, layer = "census"
    )
    return(to)
}

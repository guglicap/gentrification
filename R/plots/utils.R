plots_utils_targets <- list(
    tar_target(
        plots_base_theme,
        command = {
            theme_bw() +
                theme(
                    text = element_text(size = 24),
                    axis.title = element_blank(),
                    panel.grid = element_blank()
                )
        }
    ),
    tar_target(
        plots_bbox,
        command = {
            master_grid |> sf::st_bbox()
        }
    ),
    tar_target(
        plots_lom_outline,
        {
            master_grid |>
                dplyr::select(geometry) |>
                sf::st_union() |>
                sfheaders::sf_remove_holes()
        }
    ),
    tar_target(
        plots_prov_labels,
        command = {
            master_grid |>
                dplyr::filter(mun %in% .capoluoghi) |>
                dplyr::group_by(prov) |>
                dplyr::summarise(
                    geometry = st_union(geometry)
                ) |>
                dplyr::mutate(geom = st_centroid(geometry))
        }
    )
)

.capoluoghi <- c(
    "BERGAMO",
    "BRESCIA",
    "COMO",
    "CREMA",
    "LECCO",
    "LODI",
    "MONZA",
    "MILANO",
    "MANTOVA",
    "PAVIA",
    "SONDRIO",
    "VARESE"
)

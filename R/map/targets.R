map_raw_files <- list(
    tar_target(
        raw_mun, "data/limiti_comunali_2020.geojson",
        format = "file"
    )
)

map_targets <-
    list(
        tar_target(
            map_mun, map_build_mun(raw_mun)
        ),
        tar_target(
            master_grid,
            map_build_master_grid(map_mun)
        ),
        tar_target(
            export_master_grid,
            map_write_master_grid(master_grid),
            format = "file"
        ),
        tar_target(
            map_geom_ids,
            {
                master_grid |>
                    st_drop_geometry() |>
                    tibble() |>
                    distinct()
            }
        )
    )

map_raw_files <- list(
    tar_target(
        raw_mun, "data/mun_it.gpkg",
        format = "file"
    ),
    tar_target(
        raw_mi_submun,
        "data/banchedati-cap-zone-demo-database/CAPZONE_Milano.shp",
        format = "file"
    ),
    tar_target(
        raw_pointcaps,
        "data/pointcaps_lom2020/pointcaps_lom2020.shp",
        format = "file"
    )
)

map_targets <-
    list(
        tar_target(
            map_mun, map_build_mun(raw_mun)
        ),
        tar_target(
            map_submunicipal_mun_list,
            command = {
                income_submunicipal_mun_list
            }
        ),
        tar_target(
            map_submun_poly_list,
            command = {
                submun_polys <- list()
                purrr::map(
                    map_submunicipal_mun_list,
                    \(mun) {
                        outline <- map_extract_mun_poly(
                            map_mun, mun
                        )
                        map_generate_submun_poly(
                            mun,
                            outline$prov,
                            raw_pointcaps,
                            outline
                        )
                    }
                )
            }
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
                    select(-prov) |>
                    distinct()
            }
        )
    )

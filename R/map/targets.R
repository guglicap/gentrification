map_raw_files <- list(
    tar_target(
        raw_mun, "data/limiti_comunali_2020.geojson",
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
            outline_mi, map_extract_mun_poly(map_mun, "MILANO")
        ),
        tar_target(
            outline_bs, map_extract_mun_poly(map_mun, "BRESCIA")
        ),
        tar_target(
            outline_bg, map_extract_mun_poly(map_mun, "BERGAMO")
        ),
        tar_target(
            map_mi,
            map_generate_milan_submun(raw_mi_submun, outline_mi)
        ),
        tar_target(
            map_bs,
            map_generate_submun_poly("Brescia", "BS", raw_pointcaps, outline_bs)
        ),
        tar_target(
            map_bg,
            map_generate_submun_poly("Bergamo", "BG", raw_pointcaps, outline_bg)
        ),
        tar_target(
            master_grid,
            map_build_master_grid(map_mun, map_mi, map_bs, map_bg)
        ),
        tar_target(
            export_master_grid,
            map_write_master_grid(master_grid),
            format = "file"
        )
    )

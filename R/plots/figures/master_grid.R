figure_targets <- append(figure_targets, tar_target(
    figure_master_grid,
    command = {
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

        path <- "figures/master_grid.pdf"
        master_grid |>
            ggplot() +
            plots_base_theme +
            geom_sf(
                data = plots_lom_outline,
                color = "black",
                fill = NA,
                linewidth = 1,
            ) +
            geom_sf(aes(fill = prov, alpha = mun %in% .capoluoghi), color = "#88888888") +
            geom_sf_label(
                data = plots_prov_labels,
                aes(label = prov),
                size = 4
                # color = "grey15"
            ) +
            scale_fill_viridis_d(name = "Province", option = "turbo") +
            scale_alpha_discrete(range = c(0.4, 1), guide = "none") +
            theme(
                axis.text = element_blank(),
                axis.ticks = element_blank(),
            ) +
            theme(
                legend.position = c(.95, .95),
                legend.justification = c("right", "top"),
                legend.box.just = "right",
                legend.margin = margin(6, 6, 6, 6)
            )
        ggsave(path, device = cairo_pdf, width = 8, height = 8)
        path
    }, format = "file"
))

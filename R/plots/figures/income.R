figure_targets <- append(figure_targets, tar_target(
    figure_income_static,
    command = {
        path <- "figures/income_static.pdf"
        .x <- income_percentile_pop |>
            left_join(
                master_grid,
                by = join_by(mun, zip)
            ) |>
            filter(
                year %in% c(2021, 2011)
            ) |>
            st_sf() |>
            mutate(
                bin_pop = (bin_pop - median(bin_pop)) / sd(bin_pop),
                .by = percentile_bin
            )
        .x |>
            ggplot() +
            plots_base_theme +
            geom_sf(
                data = plots_lom_outline,
                color = "black",
                fill = "grey50",
                linewidth = 1,
            ) +
            geom_sf(aes(fill = bin_pop), color = NA, linewidth = 0) +
            coord_sf(
                xlim = c(plots_bbox$xmin, plots_bbox$xmax),
                ylim = c(plots_bbox$ymin, plots_bbox$ymax)
            ) +
            theme(
                axis.text = element_blank(),
                axis.ticks = element_blank(),
                legend.text = element_text(size = 8),
                legend.title = element_text(size = 14),
                legend.key.size = unit(12, "pt")
            ) +
            scale_fill_viridis_c(
                name = expression(paste(f[i], " (normalized)")),
                limits = c(
                    quantile(.x[["bin_pop"]], 0.005),
                    quantile(.x[["bin_pop"]], 0.995)
                ),
                option = "magma",
                oob = scales::squish
            ) +
            guides(
                fill = guide_colorbar(barwidth = 30)
            ) +
            theme(
                axis.text = element_blank(),
                axis.ticks = element_blank(),
                legend.text = element_text(size = 10),
                legend.title = element_text(size = 24),
                legend.key.size = unit(14, "pt"),
                legend.position = "bottom"
            ) +
            facet_grid(
                rows = vars(year),
                cols = vars(percentile_bin)
            )
        ggsave(path, device = cairo_pdf, width = 12, height = 8)
        path
    }, format = "file"
))

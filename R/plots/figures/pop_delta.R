figure_targets <- append(figure_targets, tar_target(
    figure_pop_delta,
    command = {
        path <- "figures/pop_delta.pdf"
        census_10y_delta |>
            ggplot() +
            plots_base_theme +
            geom_sf(
                data = plots_lom_outline,
                color = "black",
                linewidth = 1,
            ) +
            geom_sf(
                aes(fill = pop_delta_rel),
                color = NA
            ) +
            geom_sf_text(
                data = plots_prov_labels,
                aes(label = prov),
                size = 4
            ) +
            scale_fill_gradient2(
                name = expression(paste(Delta, tilde(P))),
                low = "blue",
                mid = "white",
                high = "red",
                limits = c(
                    quantile(census_10y_delta$pop_delta_rel, 0.005, na.rm = TRUE),
                    quantile(census_10y_delta$pop_delta_rel, 0.995, na.rm = TRUE)
                ),
                oob = scales::squish
            ) +
            guides(
                fill = guide_colorbar(barwidth = 25)
            ) +
            theme(
                axis.text = element_blank(),
                axis.ticks = element_blank(),
                legend.text = element_text(size = 10),
                legend.title = element_text(size = 24),
                legend.key.size = unit(14, "pt"),
                legend.position = "bottom"
            )
        ggsave(path, device = cairo_pdf, width = 8, height = 8)
        path
    }, format = "file"
))

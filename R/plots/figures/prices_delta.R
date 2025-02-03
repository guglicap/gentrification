figure_targets <- append(figure_targets, tar_target(
    figure_prices_delta,
    command = {
        path <- "figures/prices_delta.pdf"
        prices_10y_delta |>
            st_sf() |>
            filter(
                !is.na(property_type), !is.na(contract_type)
            ) |>
            ggplot() +
            plots_base_theme +
            geom_sf(
                data = plots_lom_outline,
                color = "black",
                fill = "grey50",
            ) +
            geom_sf(
                aes(fill = property_price_delta),
                color = NA,
            ) +
            geom_sf_text(
                data = plots_prov_labels,
                aes(label = prov),
                size = 2
            ) +
            coord_sf(
                xlim = c(plots_bbox$xmin, plots_bbox$xmax),
                ylim = c(plots_bbox$ymin, plots_bbox$ymax)
            ) +
            theme(
                axis.text = element_blank(),
                axis.ticks = element_blank(),
                legend.text = element_text(size = 6),
                legend.key.size = unit(12, "pt"),
                legend.title = element_text(size = 18),
                legend.position = "bottom",
                strip.text = element_text(size = 18),
            ) +
            guides(fill = guide_colorbar(barwidth = 30)) +
            scale_fill_gradient2(
                name = expression(paste(Delta, tilde(T))),
                low = "blue",
                mid = "white",
                high = "red",
                limits = c(
                    quantile(prices_10y_delta$property_price_delta, 0.005, na.rm = TRUE),
                    quantile(prices_10y_delta$property_price_delta, 0.995, na.rm = TRUE)
                ),
                oob = scales::squish
            ) +
            facet_grid(
                rows = vars(contract_type),
                cols = vars(property_type),
                switch = "y"
            )
        ggsave(path, device = cairo_pdf, width = 8, height = 8 / 3 * 2)
        path
    }, format = "file"
))

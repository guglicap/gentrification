figure_targets <- append(figure_targets, tar_target(
    figure_pop_static,
    command = {
        path <- "figures/pop_static.pdf"
        census_interpolated |>
            mutate(
                population = log10(population)
            ) |>
            ggplot() +
            plots_base_theme +
            geom_sf(
                data = plots_lom_outline,
                color = "black",
                linewidth = 1,
            ) +
            geom_sf(
                aes(fill = population),
                color = NA
            ) +
            geom_sf_text(
                data = plots_prov_labels,
                aes(label = prov),
                size = 4
            ) +
            scale_fill_viridis_c(
                name = expression(paste(log[10], P)),
                option = "magma"
            ) +
            guides(
                fill = guide_colorbar(barwidth = 20)
            ) +
            theme(
                axis.text = element_blank(),
                axis.ticks = element_blank(),
                legend.text = element_text(size = 10),
                legend.title = element_text(size = 24),
                legend.key.size = unit(14, "pt"),
                legend.position = "bottom"
            ) +
            facet_wrap(~year)
        ggsave(path, device = cairo_pdf, width = 10, height = 10 / 3 * 2 - 1)
        path
    }, format = "file"
))

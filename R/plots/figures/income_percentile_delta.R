figure_targets <- append(figure_targets, tar_target(
    figure_income_percentile_delta,
    command = {
        path <- "figures/income_percentile_delta.pdf"
        left_join(
            master_grid,
            income_10y_percentile_delta,
            by = join_by(mun, zip)
        ) |>
            mutate(
                percentile_bin = stringr::str_glue(
                    "paste(Delta, f['{percentile_bin}'])"
                )
            ) |>
            ggplot() +
            plots_base_theme +
            geom_sf(
                data = plots_lom_outline,
                fill = NA,
                color = "black"
            ) +
            geom_sf(
                aes(fill = delta_bin_pop),
                color = NA
            ) +
            geom_sf_text(
                data = plots_prov_labels,
                aes(label = prov),
                size = 2
            ) +
            theme(
                axis.text = element_blank(),
                axis.ticks = element_blank(),
                axis.title = element_blank(),
                plot.margin = margin(0, 0, 0, 0),
                plot.background = element_blank(),
                panel.background = element_blank(),
                panel.ontop = TRUE,
                legend.margin = margin(0, 0, 0, 0),
                legend.text = element_text(size = 6),
                legend.title = element_text(size = 18),
                legend.key.size = unit(12, "pt"),
                legend.position = "bottom",
                strip.text = element_text(size = 18)
            ) +
            scale_fill_gradient2(
                name = expression(paste(Delta, f[i])),
                low = "blue",
                mid = "white",
                high = "red",
                limits = c(
                    quantile(income_10y_percentile_delta[["delta_bin_pop"]], 0.005),
                    quantile(income_10y_percentile_delta[["delta_bin_pop"]], 0.995)
                ),
                oob = scales::squish
            ) +
            guides(fill = guide_colorbar(barwidth = 25)) +
            facet_wrap(~percentile_bin, labeller = label_parsed)
        ggsave(path, device = cairo_pdf, width = 10, height = 4)
        path
    }, format = "file"
))

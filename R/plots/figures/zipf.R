zipf_figures <- list(
    tar_target(
        figure_zipf_fit,
        command = {
            path <- "figures/zipf_fit.pdf"
            zipf_fitted |>
                ggplot() +
                plots_base_theme +
                theme(
                    panel.grid.major = element_line(color = "grey90", size = 0.5)
                ) +
                geom_point(
                    aes(y = logP, x = logR)
                ) +
                geom_line(
                    aes(y = .fitted, x = logR),
                    color = "orange",
                    linewidth = 1.5,
                ) +
                geom_label(
                    data = zipf_fitcoefs,
                    aes(label = stringr::str_glue(
                        "nu == {estimate}"
                    )),
                    x = Inf, y = Inf,
                    size = 10,
                    hjust = 1, vjust = 1,
                    parse = TRUE,
                ) +
                xlab(expression(paste(log[10], R))) +
                ylab(expression(paste(log[10], P))) +
                facet_wrap(~year)
            ggsave(path, device = cairo_pdf, width = 12, height = 8)
            path
        }, format = "file"
    ),
    tar_target(
        figure_rank_delta,
        command = {
            census_rankdelta |>
                ggplot() +
                plots_base_theme +
                geom_sf(
                    data = plots_lom_outline,
                    color = "black",
                    linewidth = 1,
                ) +
                theme(
                    axis.text = element_blank(),
                    axis.ticks = element_blank(),
                    axis.title = element_blank(),
                    plot.margin = margin(r = 12, b = 18),
                    legend.text = element_text(size = 18),
                    legend.title = element_text(size = 18, margin = margin(b = 12)),
                    legend.key.size = unit(6, "pt"),
                    legend.position = "left"
                ) +
                geom_sf(aes(fill = rank_delta), color = NA) +
                geom_sf_text(data = plots_prov_labels, aes(label = prov), size = 4) +
                guides(fill = guide_colorbar(barheight = 8, reverse = TRUE)) +
                scale_fill_gradient2(
                    name = expression(paste(Delta, R)),
                    low = "red",
                    mid = "white",
                    high = "blue"
                )
        }
    ),
    tar_target(
        figure_rank_pop_scatterplot,
        command = {
            census_rankdelta |>
                ggplot(aes(x = pop_2011, y = rank_delta)) +
                plots_base_theme +
                theme(
                    axis.title = element_text(size = 18),
                    panel.grid.major = element_line(color = "grey90", size = 0.5)
                ) +
                xlab(expression(paste(log[10], (P[2011])))) +
                ylab(expression(paste(Delta, R))) +
                geom_point(alpha = 0.7)
        }
    ),
    tar_target(
        figure_rankmovements,
        command = {
            path <- "figures/rankmovements.pdf"
            box::use(cowplot[plot_grid])
            plot_grid(
                figure_rank_delta, figure_rank_pop_scatterplot,
                labels = c("A", "B"),
                labelsize = 14,
                align = "v",
                axis = "btlr",
                nrow = 1,
                ncol = 2
                # rel_height = c(0.95, 0.95)
            )
            ggsave(path, device = cairo_pdf, width = 16, height = 8)
            path
        }, format = "file"
    )
)

figure_targets <- append(figure_targets, zipf_figures)

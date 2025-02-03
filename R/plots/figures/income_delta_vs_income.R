figure_targets <- append(figure_targets, tar_target(
    figure_income_delta_vs_income,
    command = {
        path <- "figures/income_delta_vs_starting_income.pdf"
        income_percentile_pop |>
            filter(year == 2011) |>
            select(-year) |>
            inner_join(
                income_10y_percentile_delta,
                by = join_by(mun, zip, geom_id, percentile_bin)
            ) |>
            mutate(
                bin_pop = (bin_pop - median(bin_pop)) / sd(bin_pop),
                delta_bin_pop = (delta_bin_pop - median(delta_bin_pop)) / sd(delta_bin_pop)
            ) |>
            ggplot() +
            plots_base_theme +
            geom_point(
                aes(x = bin_pop, y = delta_bin_pop)
            ) +
            ylim(-2, 2)
        ggsave(
            path,
            device = cairo_pdf,
            width = 8,
            height = 8
        )
        path
    }, format = "file"
))

scale_laws_targets <- list(
    tar_target(
        scale_laws_data,
        command = {
            inner_join(
                census_interpolated |> tibble() |> select(-geometry),
                prices_interpolated_plots_version,
                by = join_by(mun, zip, year)
            )
        }
    ),
    tar_target(
        scale_laws_cond_means,
        command = {
            scale_laws_data |>
                filter(population > 0) |>
                group_by(property_type, contract_type) |>
                mutate(pop_bin = cut(
                    log10(population),
                    breaks = 10,
                )) |>
                group_by(property_type, contract_type, pop_bin) |>
                summarise(
                    x = median(population),
                    n = n(),
                    prezzo_cond_pop = mean(property_avg_price, na.rm = TRUE),
                ) |>
                filter(n > 20)
        }
    ),
    tar_target(
        scale_laws_fit,
        command = {
            scale_laws_cond_means |>
                as_tibble() |>
                group_by(property_type, contract_type) |>
                select(x, y = prezzo_cond_pop) |>
                mutate(across(everything(), log10)) |>
                ungroup() |>
                nest_by(property_type, contract_type) |>
                reframe(broom::tidy(lm(y ~ x, data))) |>
                mutate(estimate = round(estimate, digits = 2))
        }
    ),
    tar_target(
        scale_laws_fit_coefs,
        command = {
            scale_laws_fit |> filter(term == "x")
        }
    )
)

figure_targets <- append(figure_targets, tar_target(
    figure_omi_scale_laws,
    command = {
        path <- "figures/omi_scale_laws.pdf"
        scale_laws_data |>
            ggplot() +
            plots_base_theme +
            geom_point(
                aes(
                    x = population,
                    y = property_avg_price,
                    color = year
                ),
                size = 1,
                alpha = 0.5
            ) +
            guides(
                color = guide_none()
            ) +
            geom_smooth(
                aes(
                    x = population,
                    y = property_avg_price,
                ),
                color = "grey40",
                linewidth = 1,
                fullrange = TRUE,
                linetype = "dashed",
                method = "lm", se = FALSE
            ) +
            theme(
                panel.grid.major = element_line(color = "grey90", size = 0.5),
                axis.title = element_text(size = 20),
                axis.text = element_text(size = 14),
                strip.text = element_text(size = 16),
            ) +
            geom_point(
                data = scale_laws_cond_means,
                aes(x = x, y = prezzo_cond_pop),
                color = "#e77000",
                size = 5,
                shape = "diamond"
            ) +
            geom_smooth(
                data = scale_laws_cond_means,
                aes(x = x, y = prezzo_cond_pop),
                color = "#e77000",
                linewidth = 1,
                fullrange = TRUE,
                method = "lm", se = FALSE
            ) +
            geom_label(
                data = scale_laws_fit_coefs,
                aes(label = paste("nu ==", estimate)),
                x = Inf, y = Inf,
                hjust = 1, vjust = 1,
                size = 8,
                parse = TRUE
            ) +
            xlab(expression(log[10] ~ P)) +
            ylab(expression(paste("Price ", T, " [€ / mq]"))) +
            scale_x_log10(labels = function(x) log10(x)) +
            scale_y_log10() +
            facet_grid(
                cols = vars(property_type),
                rows = vars(contract_type),
                switch = "y", scales = "free"
            )
        ggsave(path, device = cairo_pdf, width = 12, height = 8)
        path
    }, format = "file"
))

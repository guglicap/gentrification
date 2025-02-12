pricemap_targets <- list(
    tar_target(
        pricemap_groups,
        {
            prices_interpolated |>
                group_by(property_type, contract_type) |>
                targets::tar_group()
        },
        iteration = "group"
    )
)


static_maps_targets <- c(static_maps_targets, pricemap_targets, tar_target(
    static_maps_prices,
    {
        .x <- pricemap_groups |>
            left_join(master_grid, by = join_by(geom_id)) |>
            st_sf() |>
            filter(property_avg_price > 0) |>
            mutate(property_avg_price = log10(property_avg_price)) |>
            mutate(property_avg_price = (property_avg_price - median(property_avg_price)) / sd(property_avg_price))

        .ct <- .x$contract_type[1]
        .pt <- .x$property_type[1]

        path <- str_glue("figures/pricemaps/{.ct}_{.pt}.pdf")
        .x |>
            ggplot() +
            ggtitle(
                str_glue("Log prices for {str_to_sentence(.ct)} of '{.pt}' (normalized)")
            ) +
            plots_base_theme +
            geom_sf(
                data = plots_lom_outline,
                color = "black",
                fill = "grey50",
                linewidth = 1,
            ) +
            geom_sf(
                aes(fill = property_avg_price),
                color = NA
            ) +
            theme(
                axis.text = element_blank(),
                axis.ticks = element_blank(),
                legend.text = element_text(size = 8),
                legend.title = element_text(size = 14),
                legend.key.size = unit(12, "pt"),
                plot.title = element_text(size = 20)
            ) +
            scale_fill_viridis_c(
                name = expression(z),
                option = "magma"
            ) +
            facet_grid(
                rows = vars(year),
                cols = vars(property_status)
            ) -> plot

        ggsave(
            path,
            plot,
            device = cairo_pdf,
            width = 8,
            height = 8 / 3 * 2
        )
        path
    },
    pattern = map(pricemap_groups),
    format = "file",
    iteration = "list"
))

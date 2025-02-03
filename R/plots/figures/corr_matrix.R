figure_targets <- append(figure_targets, tar_target(
    corr_matrix,
    command = {
        .x <- inner_join(
            select(prices_10y_delta, -prov, -geometry, -geom_id),
            st_drop_geometry(census_10y_delta) |> select(-prov),
            by = join_by(mun, zip)
        ) |>
            filter(
                property_type == "Apartments",
                contract_type == "Sales"
            ) |>
            select(
                -property_type,
                -contract_type
            ) |>
            inner_join(
                income_10y_percentile_delta,
                by = join_by(geom_id)
            ) |>
            pivot_wider(
                names_from = "percentile_bin",
                values_from = "delta_bin_pop",
                names_glue = "$paste(Delta, f['{percentile_bin}'])"
            ) |>
            rename(
                "$paste(Delta, tilde(P))" = pop_delta_rel,
                "$paste(Delta, tilde(T))" = property_price_delta
            ) |>
            select(starts_with("$"))

        box::use(corrplot[cor.mtest, corrplot])
        .x |> cor(use = "complete.obs") -> .x.cor
        .x.test <- cor.mtest(.x, conf.level = 0.95)

        path <- "figures/corr_matrix.pdf"
        cairo_pdf(path, width = 12, height = 12)
        .x.cor |>
            corrplot(
                order = "hclust",
                type = "lower",
                diag = FALSE,
                method = "circle",
                addgrid.col = "grey90",
                cl.pos = "n", cl.cex = 1.5, cl.offset = 1,
                tl.srt = 45, tl.cex = 3, tl.col = "grey30", tl.offset = 1.5,
                addCoef.col = "black", number.cex = 1.5,
                p.mat = .x.test$p,
                insig = "blank",
                sig.level = 0.01
            )
        dev.off()
        path
    },
    format = "file"
))

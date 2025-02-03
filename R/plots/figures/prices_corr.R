figure_targets <- append(figure_targets, tar_target(
    prices_corrplot,
    command = {
        prices <- prices_10y_delta |>
            select(mun, zip, property_type, contract_type, property_price_delta) |>
            filter(!is.na(contract_type), !is.na(property_type)) |>
            pivot_wider(
                names_from = c("property_type", "contract_type"),
                values_from = property_price_delta,
                names_glue = "{property_type}, {contract_type}"
            ) |>
            select(-mun, -zip)

        box::use(corrplot[cor.mtest, corrplot])
        prices_cor <- cor(prices, use = "complete.obs")
        prices_cor_sig <- cor.mtest(prices)

        path <- "figures/omi_corrplot.pdf"
        cairo_pdf(path)
        prices_cor |> corrplot(
            order = "hclust",
            type = "lower",
            diag = FALSE,
            method = "circle",
            addgrid.col = "grey90",
            cl.pos = "n",
            tl.col = "grey30",
            p.mat = prices_cor_sig$p,
            insig = "blank",
            sig.level = 0.05,
            # cl.pos = "n", cl.cex = 1.5, cl.offset = 1,
            # tl.srt = 45, tl.col = "grey30", tl.offset = 1.5,
            addCoef.col = "black"
        )
        dev.off()
        path
    },
    format = "file"
))

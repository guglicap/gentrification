income_preprocess <- function(income, regions = c("LOMBARDIA")) {
    income |>
        dplyr::mutate(
            Regione = str_standardize(Regione)
        ) |>
        dplyr::filter(
            Regione %in% regions
        ) |>
        dplyr:::rename(
            mun = `Denominazione Comune`,
            year = `Anno di imposta`
        ) |>
        dplyr::rename_with(
            ~ stringr::str_replace(
                .x, "Ammontare$", "Ammontare in euro"
            )
        ) |>
        dplyr::mutate(mun = str_standardize(mun))
}

income_merge_mun <- function(income, merge_list = list()) {
    # merge municipalities
    for (i in seq_along(merge_list)) {
        .newname <- names(merge_list)[i]
        .oldnames <- str_standardize(merge_list[[i]])

        income |>
            dplyr::filter(mun %in% .oldnames) -> .olddata

        if (nrow(.olddata) < 1) {
            next
        }

        .olddata |>
            dplyr::summarise(across(
                starts_with("Reddito"), sum
            )) -> .newdata

        .newdata |>
            dplyr::mutate(
                mun = .newname,
                zip = NA,
                year = .olddata$year[1],
            ) |>
            dplyr::relocate(mun, zip, year) -> .newdata

        income |>
            dplyr::filter(!(mun %in% .oldnames)) |>
            dplyr::bind_rows(.newdata) -> income
    }
    income
}

income_rename_mun <- function(income, rename_list = list()) {
    for (i in seq_along(rename_list)) {
        income$mun <- str_replace(
            income$mun,
            names(rename_list)[i],
            rename_list[[i]]
        )
    }
    income
}
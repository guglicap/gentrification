income_preprocess <- function(income, regions = c("LOMBARDIA")) {
    income |>
        dplyr::mutate(
            Regione = str_standardize(Regione),
            mun_code = as.double(`Codice Istat Comune`),
        ) |>
        dplyr::select(-`Codice Istat Comune`) |>
        # dplyr::filter(
        #     Regione %in% regions
        # ) |>
        dplyr:::rename(
            mun = `Denominazione Comune`,
            year = `Anno di imposta`
        ) |>
        dplyr::rename_with(
            ~ stringr::str_replace(
                .x, "Ammontare$", "Ammontare in euro"
            )
        ) |>
        dplyr::mutate(mun = str_standardize(mun)) |>
        dplyr::filter(mun_code != 0) # ignore "MANCANTE/ERRATA" region, introduced in 2019
}
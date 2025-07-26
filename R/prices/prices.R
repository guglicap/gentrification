#' Get paths to prices folder for all available years
#' @param prices_raw_folder folder containing prices folders for all available years
prices_get_years <- function(prices_raw_folder) {
    list.files(prices_raw_folder, full.names = TRUE)
}

prices_load <- function(prices_year_folder, regions = c("LOMBARDIA")) {
    # calcola l'anno a partire dal percorso
    year <- as.numeric(basename(prices_year_folder))

    # carica dati quotazioni (no geom)
    quot <- readr::read_csv2(
        file.path(prices_year_folder, "quotazioni.csv")
    )

    quot |>
        dplyr::select(
            Comune_descrizione,
            Comune_amm,
            Comune_ISTAT,
            Zona,
            Descr_Tipologia,
            Stato,
            starts_with("Compr"),
            starts_with("Loc")
        ) |>
        mutate(
            year = year,
        ) -> quot
}

prices_tidy <- function(prices_raw) {
    prices_raw |>
        tibble() |>
        mutate(
            sales = 0.5 * (Compr_min + Compr_max),
            rents = 0.5 * (Loc_min + Loc_max)
        ) |>
        mutate(
            property_type = str_replace_all(
                Descr_Tipologia,
                "\\s", "_"
            ),
            property_status = Stato,
            mun = str_standardize(Comune_descrizione),
            mun_code = as.double(
                str_sub(Comune_ISTAT, start = -6, end = -1)
            )
        ) |>
        select(
            mun,
            mun_code,
            omi_zone = Zona,
            omi_mun_code = Comune_amm,
            year,
            property_type,
            property_status,
            sales,
            rents
        ) |>
        pivot_longer(
            cols = c("sales", "rents"),
            names_to = "contract_type",
            values_to = "property_avg_price"
        ) |>
        filter(!is.na(property_avg_price))
}

prices_aggregate_mun <- function(prices_tidied, map_geom_ids) {
    prices_tidied |>
        mutate(omi_zone = str_sub(omi_zone, 1, 1)) |>
        filter(omi_zone %in% c(
            "B", "C", "D", "E"
        )) |>
        group_by(
            mun, mun_code, year, property_type, property_status, contract_type
        ) |>
        summarise(
            property_avg_price = median(property_avg_price, na.rm = TRUE)
        ) |>
        ungroup()
}

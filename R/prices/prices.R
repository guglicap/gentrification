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

    # genera lista di codici dei comuni presenti nel file quotazioni
    mun_codes <-
        quot |>
        dplyr::distinct(Comune_amm) |>
        dplyr::pull(Comune_amm)

    zones_dir <- file.path(prices_year_folder, "zone")

    # crea lista zone
    zones <- list()
    # carica zone
    for (mun_code in mun_codes) {
        zone_file <- file.path(zones_dir, str_glue("{mun_code}.kml"))
        if (!file.exists(zone_file)) {
            warning(str_glue("couldn't load zone file {zone_file}"))
            next
        }
        zone <- sf::read_sf(zone_file) |>
            dplyr::select(Name, geometry) |>
            mutate(
                Comune_amm = mun_code,
                Zona = str_match(Name, "Zona OMI (.+)")[, 2]
            ) |>
            # ignora asse z
            sf::st_zm(drop = TRUE)

        zones[[length(zones) + 1]] <- zone
    }

    # unisci lista
    dplyr::bind_rows(zones) -> zones

    quot |>
        dplyr::select(
            Comune_descrizione,
            Comune_amm,
            Zona,
            Descr_Tipologia,
            Stato,
            starts_with("Compr"),
            starts_with("Loc")
        ) -> quot

    dplyr::inner_join(
        quot, zones,
        dplyr::join_by(Comune_amm, Zona)
    ) |>
        dplyr::mutate(
            year = year,
            id = paste0(Comune_amm, " - ", Zona)
        ) |>
        sf::st_sf() |>
        sf::st_transform("EPSG:3035") |>
        sf::st_make_valid() |>
        sf::st_cast()
}

prices_tidy <- function(prices_raw) {
    prices_raw |>
        st_sf() |>
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
            mun = str_standardize(Comune_descrizione)
        ) |>
        select(
            mun,
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

#' Get paths to income folders for all years available
#' @param irpef_raw_folder folder containing income folders for all years
income_get_years <- function(irpef_raw_folder) {
    list.files(irpef_raw_folder, full.names = TRUE)
}

income_mun_merges <- list(
    "BORGO VIRGILIO" = c("borgoforte", "virgilio"),
    "SERMIDE E FELONICA" = c("sermide", "felonica"),
    "VALVARRONE" = c("introzzo", "tremenico", "vestreno"),
    "BORGOCARBONARA" = c("borgofranco sul po", "carbonara di po"),
    "ALTA VALLE INTELVI" = c("lanzo d'intelvi", "pellio intelvi", "ramponio verna"),
    "CORTEOLONA E GENZONE" = c("corteolona", "genzone"),
    "VAL BREMBILLA" = c("brembilla", "gerosa"),
    "CADREZZATE CON OSMATE" = c("cadrezzate", "osmate"),
    "COLLI VERDI" = c("canevino", "ruino", "valverde"),
    "LA VALLETTA BRIANZA" = c("perego", "rovagnate"),
    "SAN GIORGIO BIGARELLO" = c("san giorgio", "bigarello"),
    "PIADENA DRIZZONA" = c("piadena", "drizzona"),
    "CASTELGERUNDO" = c("camairago", "cavacurta"),
    "COLVERDE" = c("drezzo", "gironico", "parè"),
    "CENTRO VALLE INTELVI" = c("casasco d'intelvi", "castiglione d'intelvi", "san fedele intelvi"),
    "VERMEZZO CON ZELO" = c("vermezzo", "zelo surrigone"),
    "BORGO MANTOVANO" = c("pieve di coriano", "revere", "villa poma"),
    "CORNALE E BASTIDA" = c("cornale", "bastida de dossi"),
    "VERDERIO" = c("verderio inferiore", "verderio superiore"),
    "MACCAGNO CON PINO E VEDDASCA" = c("maccagno", "pino sulla sponda del lago maggiore", "veddasca"),
    "TREMEZZINA" = c("lenno", "mezzegra", "ossuccio", "tremezzo"),
    "SOLBIATE CON CAGNO" = c("solbiate", "cagno"),
    "TORRE DE PICENARDI" = c("torre de picenardi", "ca' d'andrea"),
    "SAN FERMO DELLA BATTAGLIA" = c("SAN FERMO DELLA BATTAGLIA", "cavallasca"),
    "BELLAGIO" = c("bellagio", "civenna"),
    "GORDONA" = c("gordona", "menarola"),
    "BIENNO" = c("bienno", "prestine"),
    "SAN GIORGIO BIGARELLO" = c("SAN GIORGIO BIGARELLO", "SAN GIORGIO DI MANTOVA"),
    "SANTOMOBONO TERME" = c("SANTOMOBONO TERME", "VALSECCA"),
    "BELLANO" = c("bellano", "vendrogno"),
    "GODIASCO SALICE TERME" = c("godiasco")
)


#' Loads income data from raw income folder (one per year)
#' @param iperf_raw_year_folder income folder for a given year
#' @param regions keep only data about these regions
income_load <- function(
    irpef_raw_year_folder, master_grid, regions = c("LOMBARDIA")) {
    income_mun <- readr::read_csv2(file.path(irpef_raw_year_folder, "comunali.csv")) |>
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

    # merge municipalities
    for (i in seq_along(income_mun_merges)) {
        .newname <- names(income_mun_merges)[i]
        .oldnames <- str_standardize(income_mun_merges[[i]])

        income_mun |>
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

        income_mun |>
            dplyr::filter(!(mun %in% .oldnames)) |>
            dplyr::bind_rows(.newdata) -> income_mun
    }

    income_mun |>
        mutate(
            mun = str_replace(mun, "CERANO DINTELVI", "CERANO INTELVI")
        ) |>
        mutate(
            mun = str_replace(mun, "GERRE DE CAPRIOLI", "GERRE DECAPRIOLI")
        ) |>
        mutate(
            mun = str_replace(mun, "PUEGNAGO DEL GARDA", "PUEGNAGO SUL GARDA")
        ) -> income_mun

    submun <- readr::read_csv2(file.path(irpef_raw_year_folder, "subcomunali.csv")) |>
        dplyr::mutate(
            Regione = str_standardize(Regione)
        ) |>
        dplyr::filter(
            Regione %in% regions
        ) |>
        dplyr:::rename(
            mun = `Denominazione Comune`,
            year = `Anno di imposta`,
            zip = CAP
        ) |>
        dplyr::mutate(mun = str_standardize(mun))

    exclude_mun <- submun |>
        distinct(mun) |>
        pull(mun)
    
    # eliminiamo i comuni dei quali andremo a prendere i dati subcomunali
    geoms <- master_grid |>
        select(mun, zip, geom_id) |>
        st_drop_geometry() |>
        tibble()

    income_mun |>
        filter(!mun %in% exclude_mun) |>
        bind_rows(submun) |>
        left_join(geoms, by = join_by(mun, zip))
}

#' Extract income bins frequencies from data and converts them to a tidy format
#' @param income_raw tbl_df with income data from raw files
#' @return a tbl_df with tidy frequencies of income bins
income_tidy_frequencies <- function(income_raw) {
    income_frequencies <- income_extract_frequencies(income_raw)
    income_frequencies |>
        dplyr::rename(
            "Reddito complessivo da NA a 0 euro - Frequenza" = "Reddito complessivo minore o uguale a zero euro - Frequenza",
            "Reddito complessivo da 120000 a NA euro" = "Reddito complessivo oltre 120000 euro - Frequenza"
        ) |>
        tidyr::pivot_longer(
            names_to = c("r.start", "r.end"),
            names_pattern = "da (\\d+|NA) a (\\d+|NA)",
            cols = contains("complessivo"),
            values_to = "freq"
        ) |>
        dplyr::mutate(
            r.start = as.numeric(r.start),
            r.end = as.numeric(r.end)
        ) |>
        arrange(mun, zip, r.end) |>
        tidyr::replace_na(
            list(freq = 0)
        )
}

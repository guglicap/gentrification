#' Get paths to income folders for all years available
#' @param irpef_raw_folder folder containing income folders for all years
income_get_years <- function(irpef_raw_folder) {
    list.files(irpef_raw_folder, full.names = TRUE)
}

#' Loads income data from raw income folder (one per year)
#' @param iperf_raw_year_folder income folder for a given year
#' @param regions keep only data about these regions
income_load <- function(irpef_raw_year_folder, geom_ids, merge_list, rename_list, regions = c("LOMBARDIA")) {
    income_mun <- readr::read_csv2(file.path(irpef_raw_year_folder, "comunali.csv")) |>
        income_preprocess(regions) |>
        income_merge_mun(merge_list) |>
        income_rename_mun(rename_list) |>
        mutate(zip = NA) |>
        left_join(geom_ids, by = join_by(mun, zip))
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

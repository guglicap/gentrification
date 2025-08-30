#' Calculate percentile bins population starting from tidy frequencies
#' @param income_tidyfreqs tibble with tidy frequencies to be used for calculation
#' @return a tbl_df with the population of the income percentile bins and the values defining the bins for every mun,zip,year
dyn_calc_percentile_population <- function(data, income_bins_cutoffs) {
    income_r_cutoffs <- purrr::map_vec(
        income_bins_cutoffs, function(x) income_calc_r_cutoff(data, x)
    )
    q <- c(0, income_bins_cutoffs, 1)
    q_bins <- cut(q[-length(q)], breaks = q, right = FALSE)
    r <- c(0, income_r_cutoffs, +Inf)
    r_bins <- cut(r[-length(r)], breaks = r, right = FALSE)
    percentile_pop <- purrr::map_vec(
        income_r_cutoffs, function(x) dyn_freq_from_r(data, x)
    )
    tibble(
        bin_pop = diff(c(0, percentile_pop, 1)),
        percentile_bin = q_bins,
        r_bin = r_bins
    )
}

dyn_freq_from_r <- function(income_tidyfreqs, r) {
    x <- income_tidyfreqs |>
        mutate(freq = replace_na(freq, 0)) |>
        group_by(r.start, r.end) |>
        summarise(freq = sum(freq), .groups = "drop") |>
        ungroup() |>
        income_compute_relfreqs() |>
        dplyr::filter(!is.na(r.end)) |>
        dplyr::mutate(freq = cumsum(freq)) |>
        dplyr::mutate(prev = dplyr::lag(freq)) |>
        dplyr::filter(r.start <= r & r.end >= r) |>
        dplyr::mutate(
            freq = prev + (r - r.start) * (freq - prev) / (r.end - r.start)
        )

    if (length(x$freq) != 1) {
        browser()
    }
    dplyr::pull(x, freq)
}

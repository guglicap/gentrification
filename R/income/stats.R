#' Calculate income cutoff value for bin_cutoff percentile cutoff
#' Percentiles are calculated wrt income_tidyfreqs aggregated
#' @param income_tidyfreqs tibble with tidy frequencies to be used for calculation
#' @param bin_cutoff percentile to calculate income cutoff
#' @return numeric(1) vector with income cutoff
income_calc_r_cutoff <- function(income_tidyfreqs, bin_cutoff) {
    income_tidyfreqs |>
        group_by(r.start, r.end) |>
        summarise(freq = sum(freq, na.rm = TRUE)) |>
        ungroup() |>
        income_r_from_percentile(bin_cutoff)
}

#' Calculate percentile bins population starting from tidy frequencies
#' groups by mun, zip, year
#' @param income_tidyfreqs tibble with tidy frequencies to be used for calculation
#' @return a tbl_df with the population of the income percentile bins and the values defining the bins for every mun,zip,year
income_calc_percentile_population <- function(income_tidyfreqs, income_bins_cutoffs) {
    income_r_cutoffs <- purrr::map_vec(
        income_bins_cutoffs, function(x) income_calc_r_cutoff(income_tidyfreqs, x)
    )
    q <- c(0, income_bins_cutoffs, 1)
    q_bins <- cut(q[-length(q)], breaks = q, right = FALSE)
    r <- c(0, income_r_cutoffs, +Inf)
    r_bins <- cut(r[-length(r)], breaks = r, right = FALSE)
    income_tidyfreqs |>
        nest_by(mun, zip, year, geom_id) |>
        reframe(
            percentile_pop = purrr::map_vec(
                income_r_cutoffs, function(x) income_freq_from_r(data, x)
            )
        ) |>
        group_by(mun, zip, year, geom_id) |>
        reframe(
            bin_pop = diff(c(0, percentile_pop, 1)),
            percentile_bin = q_bins,
            r_bin = r_bins
        ) |>
        ungroup()
}

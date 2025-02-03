income_extract_frequencies <- function(income_raw) {
    income_raw |>
        select(
            mun,
            zip,
            year,
            geom_id,
            starts_with("Reddito complessivo") &
                contains("frequenza")
        )
}

income_calc_n_contribs <- function(income_tidyfreqs) {
    income_tidyfreqs |>
        summarise(n_contribs = sum(freq, na.rm = TRUE))
}

income_compute_cumfreqs <- function(income_tidyfreqs) {
    income_compute_relfreqs(income_tidyfreqs) |>
        mutate(freq = cumsum(freq))
}

income_compute_relfreqs <- function(income_tidyfreqs) {
    income_tidyfreqs |>
        mutate(freq = freq / sum(freq, na.rm = TRUE))
}

income_r_from_percentile <- function(income_tidyfreqs, percentile = 0.5) {
    income_cumfreqs <- income_tidyfreqs |>
        arrange(r.end) |>
        income_compute_cumfreqs()

    .l <- income_cumfreqs |>
        dplyr::filter(freq <= percentile) |>
        dplyr::slice_tail(n = 1)

    .h <- income_cumfreqs |>
        dplyr::filter(freq >= percentile) |>
        dplyr::slice_head(n = 1)

    if (nrow(.l) == 0) {
        warning("no lower bound found, is the requested percentile too low?")
        return(NA)
    }

    if (nrow(.h) == 0) {
        warning("no upper bound found, is the requested percentile too high?")
        return(NA)
    }

    ret <- NA

    if (identical(.l$freq, .h$freq)) {
        ret <- .l$r.end
    } else {
        ret <- .l$r.end + (percentile - .l$freq) * (.h$r.end - .l$r.end) / (.h$freq - .l$freq)
    }

    ret
}

income_freq_from_r <- function(income_tidyfreqs, r) {
    income_tidyfreqs |>
        income_compute_relfreqs() |>
        dplyr::filter(!is.na(r.end)) |>
        dplyr::mutate(freq = cumsum(freq)) |>
        dplyr::mutate(prev = dplyr::lag(freq)) |>
        dplyr::filter(r.start <= r & r.end >= r) |>
        dplyr::mutate(
            freq = prev + (r - r.start) * (freq - prev) / (r.end - r.start)
        ) |>
        dplyr::pull(freq)
}

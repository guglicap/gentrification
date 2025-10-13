library(targets)
library(tidyverse)

tar_load(income_tidyfreqs)

x <- income_tidyfreqs |>
    filter(!is.na(r.start), !is.na(r.end))

x <- x |>
    mutate(
        cl = cut(r.end,
            breaks = c(-1, 15000, 55000, 120000),
            labels = c("L", "M", "H")
        )
    )

x <- x |>
    select(geom_id, year, freq, cl) |>
    summarise(pop = sum(freq), .by = c("geom_id", "cl", "year")) |>
    mutate(ptot = sum(pop), .by = c("geom_id", "year")) |>
    arrange(geom_id)

x <- x |>
    mutate(
        dpop = c(NA, diff(pop)),
        dyear = c(NA, diff(year)),
        .by = c("geom_id", "cl"),
    ) |>
    mutate(
        delta = dpop / dyear
    )

x <- x |> mutate(
    overrepr = pop / ptot > median(pop / ptot),
    .by = c("cl", "year")
)

y <- x |>
    filter(!is.na(delta)) |>
    slice_sample(prop = 0.1, by = c("cl", "year"))

y |> filter(!overrepr) |> ggplot() +
    geom_point(
        aes(x = log10(pop), y = dpop, color = year, shape = overrepr),
        alpha = 0.3,
        size = 5
    ) +
    ylim(-1000, 1000) +
    xlim(2.5, 5) +
    facet_wrap(~cl, scales = "free")

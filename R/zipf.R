zipf_targets <- list(
    tar_target(
        zipf_fitdata,
        command = {
            census_ranked |>
                as_tibble() |>
                select(-geometry, -mun) |>
                filter(population > 0) |>
                mutate(logP = log10(population), logR = log10(rank)) |>
                filter(logR < 2.75)
        }
    ),
    tar_target(
        zipf_fitcoefs,
        command = {
            zipf_fitdata |>
                nest_by(year) |>
                reframe(broom::tidy(lm(-logP ~ logR, data = data))) |>
                filter(term == "logR") |>
                mutate(estimate = round(estimate, digits = 2))
        }
    ),
    tar_target(
        zipf_fitted,
        command = {
            zipf_fitdata |>
                nest_by(year) |>
                reframe(
                    broom::augment(lm(logP ~ logR, data = data))
                )
        }
    )
)

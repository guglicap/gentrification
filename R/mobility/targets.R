mobility_targets <- list(
    tar_target(
        mobility_raw_11,
        command = {
            mobility_load("data/mobility/matrix_pendo2011.txt")
        }
    )
)
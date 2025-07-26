mun_codes_load <- function(codefile) {
    read_csv2(
        codefile,
        col_names = c(
            "reg_code_start",
            "reg_start",
            "prov_code_start",
            "prov_start",
            "mun_code_start",
            "mun_start",
            "mun_code_end",
            "mun_end",
            "prov_code_end",
            "prov_end",
            "reg_code_end",
            "reg_end"
        ),
        skip = 1,
        col_types = "dcdcdcdcdcdc"
    ) |> mutate(
        reg_start = str_standardize(reg_start),
        prov_start = str_standardize(prov_start),
        mun_start = str_standardize(mun_start),
        reg_end = str_standardize(reg_end),
        prov_end = str_standardize(prov_end),
        mun_end = str_standardize(mun_end)
    )
}

mun_codes_targets <- list(
    tar_target(
        mun_codes_raw_11_21,
        command = {
            mun_codes_load(
                "data/mun_codes/trans_11_21.csv"
            )
        }
    ),
    tar_target(
        mun_dict_21,
        command = {
            mun_codes_raw_11_21 |>
                select(mun_end, mun_code_end) |>
                rename(mun = mun_end, mun_code = mun_code_end) |>
                distinct()
        }
    ),
    tar_target(
        mun_dict_11,
        command = {
            mun_codes_raw_11_21 |>
                select(mun_start, mun_code_start) |>
                rename(mun = mun_start, mun_code = mun_code_start) |>
                distinct()
        }
    ),
    tar_target(
        mun_updates_11_21,
        command = {
            mun_codes_raw_11_21 |>
                group_by(mun_end) |>
                filter(n() > 1 | mun_start != mun_end) |>
                select(mun_start, mun_end) |>
                summarise(from = list(mun_start)) |>
                deframe()
        }
    )
)

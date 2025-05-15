census_raw_files <- list(
    tar_target(raw_census_path, "data/istat-raw/pop_01_19.csv", format = "file")
)

census_targets <- list(
    tar_target(
        census_raw,
        {
            read_delim_chunked(
                raw_census_path,
                callback = DataFrameCallback$new(census_read_callback),
                delim = "|"
            )
        }
    ),
    tar_target(
        census_raw_agebins,
        {
            census_raw |>
                filter(ETA1 != "TOTAL") |>
                mutate(
                    ETA1 = as.integer(str_remove(ETA1, "[A-Z_]+"))
                ) |>
                mutate(age_group = cut(ETA1,
                    breaks = c(
                        0, 18, 35, 50, 65, 100, +Inf
                    ),
                    right = FALSE
                ))
        }
    ),
    tar_target(
        census_agebins_tidied,
        {
            census_raw_agebins |>
                select(
                    -`Tipo dato`,
                    -`Classe di età`,
                    -`Seleziona periodo`,
                    -`Flag Codes`,
                    -Flags
                ) |>
                group_by(
                    ITTER107, Territorio, TIME, age_group, TIPO_DATO15
                ) |>
                summarise(Value = sum(Value, na.rm = TRUE)) |>
                ungroup() |>
                pivot_wider(
                    names_from = TIPO_DATO15,
                    values_from = Value
                )
        }
    ),
    tar_target(census_agetotal_tidied, {
        census_raw |>
            filter(ETA1 == "TOTAL") |>
            select(
                -`Tipo dato`,
                -`Classe di età`,
                -`Seleziona periodo`,
                -`Flag Codes`,
                -Flags
            ) |>
            pivot_wider(
                names_from = TIPO_DATO15,
                values_from = Value
            )
    }),
    tar_target(
        census_export_agetotal,
        {
            path <- "export/census_agetotal.csv"
            census_agetotal_tidied |> write_csv(path)
            path
        }
    ),
    tar_target(
        census_export_agebins,
        {
            path <- "export/census_agebins.csv"
            census_agebins_tidied |> write_csv(path)
            path
        }
    )
)

census_read_callback <- function(x, pos) {
    x |>
        filter(
            SEXISTAT1 == 9,
            CITTADINANZA == "TOTAL"
        ) |>
        select(
            -SEXISTAT1,
            -Sesso,
            -Cittadinanza,
            -CITTADINANZA
        )
}

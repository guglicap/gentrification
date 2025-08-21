income_raw_files <- list(
    tar_target(raw_income_folder,
        "data/Redditi",
        format = "file"
    )
)

income_params <- list(
    tar_target(
        income_bins_cutoff,
        command = {
            c(0.5, 0.9)
        }
    ),
    tar_target(
        income_merge_list,
        command = {
            list(
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
        }
    ),
    tar_target(income_rename_list,
    command = {
        list(
            "CERANO DINTELVI" = "CERANO INTELVI",
            "GERRE DE CAPRIOLI" = "GERRE DECAPRIOLI",
            "PUEGNAGO DEL GARDA" = "PUEGNAGO SUL GARDA"
        )
    })
)


income_targets <- list(
    tar_target(
        income_years,
        income_get_years(raw_income_folder),
    ),
    tar_target(
        income_raw,
        income_load(income_years, map_geom_ids, mun_updates_11_21, income_rename_list),
        pattern = map(income_years)
    ),
    tar_target(
        income_tidyfreqs,
        income_tidy_frequencies(income_raw),
        pattern = map(income_raw)
    ),
    tar_target(
        income_percentile_pop,
        income_calc_percentile_population(income_tidyfreqs, income_bins_cutoff),
        pattern = map(income_tidyfreqs)
    ),
    tar_target(
        income_mun_median,
        command = {
            income_tidyfreqs |>
                nest_by(mun, mun_code, year) |>
                mutate(r.median = income_calc_r_cutoff(data, 0.5)) |>
                select(-data) |>
                ungroup()
        }
    )
)

income_outputs <- list(
    tar_target(
        export_percentile_pop,
        command = {
            path <- file.path("export", "percentile_pop.csv")
            readr::write_csv(income_percentile_pop, path)
            path
        },
        format = "file"
    ),
    tar_target(
        export_income_mun_median,
        command = {
            path <- file.path("export", "income_median.csv")
            readr::write_csv(income_mun_median, path)
            path
        },
        format = "file"
    ),
    tar_target(
        export_income,
        command = {
            income <- full_join(
                income_percentile_pop,
                income_mun_median,
                by = join_by(mun, mun_code, year)
            )
            path <- file.path("export", "income.csv")
            readr::write_csv(income, path)
            path
        },
        format = "file"
    )
    )

income_targets <- c(income_targets, income_params, income_outputs)

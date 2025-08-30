income_params <- list(
    tar_target(
        income_bins_cutoff,
        command = {
            c(0.5, 0.9)
        }
    ),
    tar_target(
        income_years,
        income_get_years(raw_income_folder),
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
        }
    )
)
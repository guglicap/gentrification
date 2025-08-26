eu_caps <- read_sf("data/map-raw/PCODE_PT_2020_3035.gpkg")

eu_caps |>
    filter(CNTR_ID == "IT") |>
    mutate(mun = str_standardize(LAU_NAT), zip = POSTCODE) |>
    select(mun, zip) |>
    write_sf("data/pointcaps_it.gpkg", append = FALSE)

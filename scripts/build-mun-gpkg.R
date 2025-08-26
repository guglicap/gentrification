library(sf)
library(tidyverse)
source("R/lib/str-standardize.R")


reg <- read_sf("data/Limiti01012020_g/Reg01012020_g/Reg01012020_g_WGS84.shp")
prov <- read_sf("data/Limiti01012020_g/ProvCM01012020_g/ProvCM01012020_g_WGS84.shp", )
com <- read_sf("data/Limiti01012020_g/Com01012020_g/Com01012020_g_WGS84.shp")



reg <- reg |> st_drop_geometry() |> mutate(reg = str_standardize(DEN_REG)) |> select(reg, COD_REG) |> tibble()
prov <- prov |>
 st_drop_geometry() |> 
 mutate(prov = str_standardize(SIGLA)) |> 
 select(prov, COD_PROV) |>
 tibble()

com |>
    mutate(mun = str_standardize(COMUNE)) |>
    full_join(reg, by = join_by(COD_REG)) |>
    full_join(prov, by = join_by(COD_PROV)) |>
    select(mun, prov, reg) |>
    write_sf("data/mun_it.gpkg", append = FALSE)


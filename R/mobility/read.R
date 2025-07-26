mobility_load <- function(mobility_path) {
    mob <- read_table(
        mobility_path,
        col_names = c(
            "record_type",
            "housing_situation",
            "house_prov_code",
            "house_mun_code",
            "sex",
            "mov_reason",
            "dest_type",
            "dest_prov_code",
            "dest_mun_code",
            "dest_cntry_code",
            "mov_mean",
            "mov_leave_time",
            "mov_duration",
            "estimated_mov_count",
            "mov_count"
        ),
        col_types = "cdddddddddddddd_",
        na = c("ND", "+")
    )
    mob
}

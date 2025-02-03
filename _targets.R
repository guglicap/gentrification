library(targets)
library(sf)
tar_option_set(
    packages = c("sf", "tidyverse", "areal", "ggplot2"),
    controller = crew::crew_controller_local(
        workers = parallel::detectCores()
    ),
    format = "qs",
    memory = "transient",
    garbage_collection = TRUE
    # error = "null"
)

figure_targets <- list()
static_maps_targets <- list()
tar_source()
c(
    map_raw_files,
    map_targets,
    census_raw_files,
    census_targets,
    income_raw_files,
    income_targets,
    prices_raw_files,
    prices_targets,
    zipf_targets,
    scale_laws_targets,
    plots_utils_targets,
    figure_targets,
    static_maps_targets
)

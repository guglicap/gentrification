#!/usr/bin/env bash

# This script downloads the Eurostat GISCO grid (1kmsq)
# The grid contains population data for the years 2011 2015 2018 2021
# divided into 1kmsq squares covering the whole of europe
# The script also filters the downloaded dataset (huge) in order to keep
# only the data that's relevant to the analysis

# where to download the dataset
DATASET_PATH="data/census.gpkg"

# set to empty string to keep the whole dataset
SQLITE_CMD="DELETE FROM type WHERE NUTS2021_2 NOT LIKE '%ITC4%'; VACUUM" 

type -p wget > /dev/null || {
    printf "please install wget\n"
    exit 1
}

type -p sqlite3 > /dev/null || {
    printf "please install sqlite3\n"
    exit 1
}

wget -O "$DATASET_PATH" "https://gisco-services.ec.europa.eu/grid/grid_1km_surf.gpkg" || {
    printf "failed GISCO grid dowload\n"
    exit $?
}

[[ -z "$SQLITE_CMD" ]] || {
    sqlite3 "$DATASET_PATH" <<< "$SQLITE_CMD"
}

#!/usr/bin/env bash

# This script takes a zip file as input, as downloaded from Agenzia delle Entrate
# It will create the proper data/omi/<year>/{zone,quotazioni} folder structure

OMI_BASE_DIR="data/omi"
FILENAME_VALORI="quotazioni.csv"
ZONE_DIR="zone"

warn() {
    printf "\e[38;5;208m%s\e[0m\n" "$1"
}

type -p unzip >/dev/null || {
    printf "unzip needed to run this script\n"
    exit 2
}

[[ -r "$1" ]] || {
    printf "cannot read \"%s\"\n" "$1"
    exit 1
}

# shellcheck disable=SC2035
RAW_CSV="$(unzip -p "$1" *_VALORI.csv)"

HEADER="${RAW_CSV%%$'\n'*}"
DATA="${RAW_CSV#*$'\n'}"

printf "%s\n" "$HEADER"

if [[ $HEADER =~ Semestre\ ([0-9]+)/([12]) ]]; then
    YEAR="${BASH_REMATCH[1]}"
    SEMESTER="${BASH_REMATCH[2]}"
else
    printf "malformed header: %s\n" "${HEADER}"
    exit 3
fi

[[ -z $YEAR ]] && {
    printf "year variable is empty, aborting.\n"
    exit 4
}

DEST_DIR="${OMI_BASE_DIR}/${YEAR}"

data_file="${DEST_DIR}/${FILENAME_VALORI}"

mkdir -p "$DEST_DIR"
mkdir -p "${DEST_DIR}/${ZONE_DIR}"

if [[ -e $data_file ]]; then
    read -p "${data_file} exists. Overwrite? (y/n): " response
    if [[ $response == "y" ]]; then
        printf "%s" "$DATA" >"$data_file" || {
            warn "warning: prices extraction failed"
        }
    fi
else
    printf "%s" "$DATA" >"$data_file" || {
        warn "warning: prices extraction failed"
    }
fi

unzip "$1" "*.kml" -d "${DEST_DIR}/${ZONE_DIR}" || {
    warn "warning: zone extraction failed"
}

read -p "extraction done. want to remove raw file $1? (y/n): " response
if [[ $response == "y" ]]; then
    rm "$1"
fi

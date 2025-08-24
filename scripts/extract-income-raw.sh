#!/usr/bin/env bash

# This script takes a zip file as input, as downloaded from Agenzia delle Entrate
# It will create the proper data/omi/<year>/{zone,quotazioni} folder structure

INCOME_BASE_DIR="data/Redditi"

warn() {
    printf "\e[38;5;208m%s\e[0m\n" "$1"
}

type -p unzip >/dev/null || {
    printf "unzip needed to run this script\n"
    exit 2
}

filename="$1"

[[ -r "$filename" ]] || {
    printf "cannot read \"%s\"\n" "$filename"
    exit 1
}

if [[ $filename =~ ([0-9]{4}).zip ]]; then
    YEAR="${BASH_REMATCH[1]}"
else
    printf "cannot find year in filename: %s\n" "${filename}"
    exit 3
fi

# shellcheck disable=SC2035
RAW_MUN="$(unzip -p "$filename" *_comunale*.csv)"

if [[ -z ${RAW_MUN} ]]; then
    warn "cannot read zip file"
    exit 2
fi

out_dir="${INCOME_BASE_DIR}/${YEAR}"
out_file="${out_dir}/comunali.csv"
mkdir -p "${out_dir}"
printf "%s" "${RAW_MUN}" > "$out_file"

# re-encode iso-8859-1 encoded csv files to utf-8
if [[ "$(file -bi "${out_file}")" =~ iso-8859-1 ]]; then
    iconv -f iso-8859-1 -t utf-8 -o /tmp/iconv.csv "${out_file}" && \
        mv /tmp/iconv.csv "${out_file}"
fi
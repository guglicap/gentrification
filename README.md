# Statistical analysis of population, income and housing prices in the Lombardy region
This is the code for a bachelor thesis titled "Statistical analysis of population changes in the Lombardy region in relation to income and housing prices" by G. Caprotti and S. Zapperi.

## Project overview
The project is structured as a data pipeline, running on the `targets` framework.
Please refer to the [targets package documentation](https://books.ropensci.org/targets/) for a thorough description of the framework.

The pipeline depends on the raw data in the `data` folder and exports datasets in the `export` folder and figures in the `figures` folder.

The following R packages need to be installed:

```plaintext
tidyverse
sf
areal
ggplot2
corrplot
rmapshaper
sqids
box
scales
cowplot
purrr
```

## Raw data
### Population data
Due to licensing, the Eurostat GISCO grid used to compute population estimates cannot be provided.
The pipeline expects such a grid to be provided as `data/census.gpkg`.

For convenience, a simple script is provided to download the (huge) grid and filter it in order to keep only the portion covering Lombardy.
The script is `scripts/download-census-eurostat.sh`, needs `wget` and `sqlite3` and is properly commented should one want to change its default filtering behavior.

### OMI data
Due to licensing, raw OMI data cannot be provided in the `data` folder.

In order to run the pipeline successfully, one needs to download OMI data from "Agenzia delle Entrate -> Area Riservata -> Fornitura dati OMI".

Downloaded data need manual intervetion in order to successfully be parsed by the pipeline, specifically the following example folder structure is expected:

```plaintext
data/omi
├── 2011 # subfolders corresponding to years
│   ├── quotazioni.csv # csv file with omi data
│   └── zone # folder containing kml files for omi zones
└── 2021
    ├── quotazioni.csv
    └── zone
```

### Income data
Raw income data are provided by "Ministero dell'Economia e delle Finanze" under [CC-BY-3.0-IT](https://creativecommons.org/licenses/by/3.0/it/) license on [their OpenData](https://www1.finanze.gov.it/finanze/analisi_stat/public/index.php?opendata=yes) page.
As such, raw income data is already available in the `data` folder and doesn't need manual intervention.

Should one desire to add more data, here is the expected folder structure:

```plaintext
data/Redditi
├── 2011 # subfolders corresponding to years
│   ├── comunali.csv # municipal income data
│   └── subcomunali.csv # submunicipal income data
```

## Interpolated datasets
Interpolated datasets are available in the `export` folder.

Non-`gpkg` datasets contain a `geom_id` column, which can be matched with the corresponding `geom_id` column in the `master_grid.gpkg` file in order to associate the data to the geometry.
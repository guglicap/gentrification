FROM rocker/r-ver:4.5.1

RUN mkdir -p /app
WORKDIR /app

RUN apt-get update && apt-get install -y libglpk-dev
RUN apt-get install -y libudunits2-dev
RUN apt-get install -y libproj-dev
RUN apt-get install -y libgdal-dev

RUN R -e "install.packages('crew')"
RUN R -e "install.packages('tidyr')"
RUN R -e "install.packages('tidyverse')"
RUN R -e "install.packages('sf')"
RUN R -e "install.packages('targets')"
RUN R -e "install.packages('purrr')"
RUN R -e "install.packages('areal')"
RUN R -e "install.packages('ggplot2')"
RUN R -e "install.packages('tarchetypes')"
RUN R -e "install.packages('qs2')"
RUN R -e "install.packages('rmapshaper')"
RUN R -e "install.packages('devtools')"
RUN R -e 'devtools::install_github("sqids/sqids-r")'

CMD ["Rscript", "-e", "targets::tar_make()"]
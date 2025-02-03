# str_standardize viene usata come workaround per
# risolvere problemi che sorgono nei join tra dataset diversi
# legati ai diversi modi di scrivere nomi dei comuni
str_standardize <- function(x) {
    x <- stringr::str_to_upper(x)
    # rimuovi accenti
    x <- stringi::stri_trans_general(x, id = "Latin-ASCII")
    # trattini -> spazi
    x <- stringr::str_replace_all(x, "-", " ")
    # rimuovi apostrofi
    x <- stringr::str_replace_all(x, "'", "")
    # rimuovi backtick al posto di accento
    x <- stringr::str_replace_all(x, "`", "")
    # rimuovi punteggiatura
    x <- stringr::str_replace_all(x, "\\.", "")
    # spazi multipli -> singolo spazio
    x <- stringr::str_replace_all(x, "\\s{1,}", " ")
    x
}

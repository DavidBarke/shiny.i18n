#' Translator options
.translator_options <- list(
  cultural_bignumer_mark = NULL,
  cultural_punctuation_mark = NULL,
  cultural_date_format = NULL
)

#' Translator R6 Class
#'
#' This creates shinny.i18n Translator object used for translations.
#' Now you can surround the pieces of the text you want to translate by
#' one of the translate statements (ex.: \code{Translator$t("translate me")}).
#' Find details in method descriptions below.
#'
#' @importFrom jsonlite fromJSON
#' @import methods
#' @import shiny
#' @export
#' @examples
#' \dontrun{
#'   i18n <- Translator$new(translation_json_path = "translation.json") # translation file
#'   i18n$set_translation_language("it")
#'   i18n$t("This text will be translated to Italian")
#' }
#'
#' # Shiny example
#' if (interactive()) {
#' library(shiny)
#' library(shiny.i18n)
#'  #to run this example  make sure that you have a translation file
#'  #in the same path
#' i18n <- Translator$new(translation_json_path = "examples/data/translation.json")
#' i18n$set_translation_language("pl")
#' ui <- fluidPage(
#'   h2(i18n$t("Hello Shiny!"))
#' )
#' server <- function(input, output) {}
#' shinyApp(ui = ui, server = server)
#' }
Translator <- R6::R6Class(
  "Translator",
  public = list(
    #' @description
    #' Initialize the Translator with data
    #' @param translation_csvs_path character with path to folder containing csv
    #' translation files. Files must have "translation_" prefix, for example:
    #' \code{translation_<LANG-CODE>.csv}.
    #' @param translation_csv_config character with path to configuration file for
    #' csv option.
    #' @param translation_json_path character with path to JSON translation file.
    #' See more in  Details.
    #' @param separator_csv separator of CSV values (default ",")
    #' @param automatic logical flag, indicating if i18n should use an automatic
    #' translation API.
    initialize = function(translation_json_path) {
      private$dict <- jsonlite::fromJSON(translation_json_path)

      private$languages <- names(private$dict)

      private$language <- private$languages[1]
    },

    #' @description
    #' Get dictionnary
    get_dict = function() private$dict,

    #' @description
    #' Get all available languages
    get_languages = function() private$languages,

    #' @description
    #' Get current target translation language
    get_language = function() private$language,

    #' @description
    #' Translates 'keyword' to language specified by 'set_translation_language'
    #' @param keyword character or vector of characters with a word or
    #' expression to translate
    #' @param session Shiny server session (default: current reactive domain)
    translate = function(keyword, ...) {
      params <- list(...)

      translation <- private$raw_translate(keyword)

      translation <- private$interpolate(translation, params)

      shiny::span(
        class = 'i18n',
        `data-key` = keyword,
        `data-params` = paste(params, collapse = ","),
        translation
      )
    },

    #' @description
    #' Wrapper to \code{translate} method.
    #' @param keyword Character or vector of characters with a word or
    #' expression to translate
    t = function(keyword, ...) {
      self$translate(keyword, ...)
    },

    #' @description
    #' Specify language of translation. It must exist in 'languages' field.
    #' @param language character with a translation language code
    set_language = function(language) {
      if (!(language %in% private$languages)) {
        stop(
          sprintf("'%s' not in Translator object languages", language)
        )
      }

      private$language <- language
    }
  ),
  private = list(
    language = character(),
    languages = character(),
    dict = NULL,

    interpolate = function(translation, params) {
      dict <- private$dict[[private$language]]
      dict$p_ <- params

      old_translation <- ""

      while(
        stringr::str_detect(translation, "\\$\\{")
        && old_translation != translation
      ) {
        old_translation <- translation
        translation <- stringr::str_interp(translation, dict)
      }

      translation
    },

    raw_translate = function(keyword) {
      translation <- private$dict[[private$language]][[keyword]]

      if (is.null(translation)) {
        warning(
          sprintf(
            "There is no translation for key %s and language %s",
            keyword, private$language
          )
        )
      }

      translation
    }
  )
)

#' Translator R6 Class
#'
#' Instances of this class may be used to translate
#'
#' @export
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
    #' Get dictionary
    get_dict = function() private$dict,

    #' @description
    #' Get all available languages
    get_languages = function() private$languages,

    #' @description
    #' Get current target translation language
    get_language = function() private$language,

    i = function(expr, ...) {
      params <- list(...)

      translation <- private$interpolate(expr, params)

      shiny::span(
        class = 'i18n-expr',
        `data-expr` = expr,
        `data-params` = paste(params, collapse = ","),
        translation
      )
    },

    i_chr = function(expr, ...) {
      params <- list(...)

      private$interpolate(expr, params)
    },

    #' @description
    #' Translates 'keyword' to language specified by 'set_translation_language'
    #' @param keyword character or vector of characters with a word or
    #' expression to translate
    #' @param session Shiny server session (default: current reactive domain)
    t = function(keyword, ...) {
      params <- list(...)

      translation <- private$translate(keyword)

      translation <- private$interpolate(translation, params)

      shiny::span(
        class = 'i18n',
        `data-key` = keyword,
        `data-params` = paste(params, collapse = ","),
        translation
      )
    },

    t_chr = function(keyword, ...) {
      params <- list(...)

      translation <- private$translate(keyword)

      private$interpolate(translation, params)
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

    translate = function(keyword) {
      translation <- private$dict[[private$language]][[keyword]]

      if (is.null(translation)) {
        warning(
          sprintf(
            "There is no translation for key %s and language %s",
            keyword, private$language
          )
        )

        # Fall back to keyword
        translation <- keyword
      }

      translation
    }
  )
)

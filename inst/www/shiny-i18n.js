var shinyi18n = new Shiny.InputBinding();

let translate = function(key, new_lang) {
  return(i18n_translations
        .filter(cell => cell._row == key)
        .map(result => result[new_lang])[0]
  );
};

String.prototype.format = function() {
  var x = this;

  for (const i in arguments) {
    x = x.replace("{" + i + "}", arguments[i]);
  }

  return x;
};

$.extend(shinyi18n, {
  find: function(scope) {
    return $(scope).find('#i18n-state');
  },
  getValue: function(el) {
    var new_lang = $(el).data("lang");
    if (new_lang === undefined) return;
    $(document).find('.i18n').each(function() {
      var $word = $(this);
      var key = $word.data('key');
      var key_translated = translate(key, new_lang);
      var params = $word.attr('data-params').split(",");
      key_translated = key_translated.format(...params);
      $word.html(key_translated);
    });
    return new_lang;
  },
  subscribe: function(el, callback) {
    $(el).on('change', callback);
  },
  receiveMessage: function(el, data) {
    $(el).data('lang', data.lang);
    $(el).trigger('change');
  },
  getRatePolicy: function() {
    return {
      policy: 'debounce',
      delay: 250
    };
  }
});
Shiny.inputBindings.register(shinyi18n, 'shiny.shinyi18n');

var shinyi18n = new Shiny.InputBinding();

let translate = function(key, language) {
  return i18nDict[language][key];
};

String.prototype.interpolate = function(obj) {
  let parts = this.split(/\$\{(?!\d)[\w]*\}/);
  let args = this.match(/[^{\}]+(?=})/g) || [];
  let params = args.map(arg => obj[arg] || '${' + arg + '}');

  return String.raw({raw: parts}, ...params);
};

String.prototype.interpolateParams = function(params) {
  var str = this;

  params.forEach((param, index) => {
    pattern = "${p_[[" + (index + 1) + "]]}";
    str = str.replace(pattern, param);
  });

  return str.valueOf();
};

$.extend(shinyi18n, {
  find: function(scope) {
    return $(scope).find('#i18n-state');
  },

  getValue: function(el) {
    var language = $(el).data("language");

    if (language === undefined) return;

    $(document).find('.i18n').each(function() {
      var $word = $(this);
      var key = $word.data('key');
      var params = $word.attr('data-params').split(",");

      var translation = translate(key, language)
        .interpolate(i18nDict)
        .interpolateParams(params);

      $word.html(translation);
    });

    return language;
  },

  subscribe: function(el, callback) {
    $(el).on('change', callback);
  },

  receiveMessage: function(el, data) {
    $(el).data('language', data.language);
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

var i18n = new Shiny.InputBinding();

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
    str = str.replaceAll(pattern, param);
  });

  return str.valueOf();
};

$.extend(i18n, {
  find: function(scope) {
    return $(scope).find('#i18n-state');
  },

  getValue: function(el) {
    return $(el).data("language");
  },

  setValue: function(el) {
    var language = data.language;
    $(el).data('language', language);

    console.log("Start translation");
    $(document).find('.i18n').each(function() {
      var $word = $(this);
      var keyword = $word.attr('data-key');
      var params = $word.attr('data-params').split(",");

      var translation = translate(keyword, language);

      translation = that.interpolate(translation, params, language);

      $word.html(translation);
    });

    $(document).find('.i18n-expr').each(function() {
      var $word = $(this);
      var expr = $word.attr('data-expr');
      var params = $word.attr('data-params').split(",");

      var translation = that.interpolate(expr, params, language);

      $word.html(translation);
    });
    console.log("Finish translation");
  },

  interpolate: function(x, params, language) {
    // Apply interpolation as long as ${ is present in translation and
    // translation changes by interpolation
    var oldX;
    while (x.includes("${") && x !== oldX) {
      oldX = x;
      x = x
        .interpolate(i18nDict[language])
        .interpolateParams(params);
    }

    return x;
  },

  subscribe: function(el, callback) {
    $(el).on('change', callback);
  },

  receiveMessage: function(el, data) {
    this.setValue(el, data);
    $(el).trigger('change');
  },

  getRatePolicy: function() {
    return {
      policy: 'debounce',
      delay: 250
    };
  }
});

Shiny.inputBindings.register(i18n, 'i18n');

var Application, LOGLEVEL, Languages, debug, info, p, _log,
  __slice = [].slice;

Application = (function() {

  Application.locale = 'en-US';

  function Application() {
    var value;
    p('Application instance created');
    if (location.hash != null) {
      value = location.hash.substr(1);
      this.locale = value;
    }
    this.languages = new Languages(this.locale);
  }

  Application.prototype.init = function() {
    var _this = this;
    this.languages.load(function() {
      return _this.languages.replace();
    });
    this.bindGlobalEvents();
    return this.bindNavigation();
  };

  Application.prototype.bindNavigation = function() {
    var $navLinks;
    $navLinks = $('nav a');
    return $navLinks.filter(':first').on('click', function() {
      return alert(app.languages.Common.FirstNavigationButton);
    });
  };

  Application.prototype.bindGlobalEvents = function() {
    return $(window).on('hashchange', function() {
      return app.onHashChanged();
    });
  };

  Application.prototype.onHashChanged = function() {
    var _this = this;
    app.locale = location.hash.substr(1);
    app.languages.locale = app.locale;
    return app.languages.load(function() {
      return app.languages.replace();
    });
  };

  return Application;

})();

Languages = (function() {

  function Languages(locale, path, resx, knownLocales) {
    this.locale = locale != null ? locale : 'en-US';
    this.path = path != null ? path : 'languages/';
    this.resx = resx != null ? resx : ['Common'];
    this.knownLocales = knownLocales != null ? knownLocales : ['en-US', 'en-GB'];
    this.neutralLocale = 'en-US';
    if (this.knownLocales.indexOf(this.locale === -1)) {
      p("locale '" + this.locale + "' is not in the list of known locales. using neutral locale '" + this.neutralLocale);
      this.locale = this.neutralLocale;
    }
  }

  Languages.prototype.load = function(callback) {
    var count, localeSegment, resx, _i, _len, _ref, _results,
      _this = this;
    p("loading locale files: " + this.locale);
    count = this.resx.length;
    if (this.neutralLocale === this.locale) {
      localeSegment = '';
    } else {
      localeSegment = "." + this.locale;
    }
    _ref = this.resx;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      resx = _ref[_i];
      _results.push((function(resx) {
        var settings;
        settings = {
          url: "" + _this.path + resx + localeSegment + ".resx",
          success: function(data) {
            _this.parseXML(data, resx);
            if (--count === 0) {
              return callback();
            }
          },
          dataType: 'xml',
          error: function() {
            throw "failed loading resource: " + resx + localeSegment + ".resx";
            return $.get("" + _this.path + resx + ".resx", function(data) {
              p('recovered with neutral locale');
              _this.parseXML(data, resx);
              if (--count === 0) {
                return callback();
              }
            }, 'xml');
          }
        };
        return $.ajax(settings);
      })(resx));
    }
    return _results;
  };

  Languages.prototype.parseXML = function(xml, propName) {
    var obj, root, tag, tags, _i, _len;
    obj = {};
    if (xml.hasChildNodes()) {
      root = xml.childNodes[0];
      tags = root.getElementsByTagName('data');
      for (_i = 0, _len = tags.length; _i < _len; _i++) {
        tag = tags[_i];
        obj[tag.getAttribute('name')] = tag.childNodes[1].childNodes[0].data;
      }
      this[propName] = obj;
    }
    return obj;
  };

  Languages.prototype.localDate = function() {
    $.datepicker.regional['en-US'] = $.datepicker.regional[''];
    return $.datepicker.setDefaults($.datepicker.regional[this.culture]);
  };

  Languages.prototype.replace = function($target) {
    var $elements,
      _this = this;
    if ($target != null) {
      $elements = $target.find('[data-localized-string]');
    } else {
      $elements = $('[data-localized-string]');
    }
    $elements.each(function(index, element) {
      var $element, localizedValue;
      $element = $(element);
      localizedValue = _this.getLocalizedValue($element.attr('data-localized-string'));
      return $element.text(localizedValue);
    });
    if ($target != null) {
      $elements = $target.find('[data-localized-placeholder]');
    } else {
      $elements = $('[data-localized-placeholder]');
    }
    $elements.each(function(index, element) {
      var $element, localizedValue;
      $element = $(element);
      localizedValue = _this.getLocalizedValue($element.attr('data-localized-placeholder'));
      return $element.attr('placeholder', localizedValue);
    });
    if ($target != null) {
      $elements = $target.find('[data-localized-title]');
    } else {
      $elements = $('[data-localized-title]');
    }
    $elements.each(function(index, element) {
      var $element, localizedValue;
      $element = $(element);
      localizedValue = _this.getLocalizedValue($element.attr('data-localized-title'));
      return $element.attr('title', localizedValue);
    });
    if ($target != null) {
      $elements = $target.find('[data-localized-button]');
    } else {
      $elements = $('[data-localized-button]');
    }
    $elements.each(function(index, element) {
      var $element, localizedValue;
      $element = $(element);
      localizedValue = _this.getLocalizedValue($element.attr('data-localized-button'));
      return $element.button('option', 'label', localizedValue);
    });
    if ($target != null) {
      $elements = $target.find('[data-localized-value]');
    } else {
      $elements = $('[data-localized-value]');
    }
    return $elements.each(function(index, element) {
      var $element, localizedValue;
      $element = $(element);
      localizedValue = _this.getLocalizedValue($element.attr('data-localized-value'));
      return $element.val(localizedValue);
    });
  };

  Languages.prototype.getLocalizedValue = function(key) {
    var localizedName, localizedValue;
    localizedName = key.split('.');
    localizedValue = this[localizedName[0]][localizedName[1]];
    if (!(localizedValue != null)) {
      debug("Localized value not found for key \"" + key + "\"");
    }
    if (!(localizedValue != null)) {
      localizedValue = "!!!" + key + "!!!";
    }
    return localizedValue = localizedValue.replace('&', '');
  };

  return Languages;

})();

LOGLEVEL = 3;

p = info = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  if (console) {
    console.info(args);
  }
  if (LOGLEVEL < 3) {
    return;
  }
  return _log.apply(null, args);
};

debug = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  if (console) {
    if (!console.log.apply) {
      console.log(args);
    }
  }
  if (LOGLEVEL < 2) {
    return;
  }
  return _log.apply(null, args);
};

_log = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  if (console) {
    if (console.log.apply) {
      return console.log.apply(console, args);
    }
  }
};

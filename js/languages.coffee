class Languages
  constructor: (@locale = 'en-US', @path = 'languages/', @resx = ['Common'], @knownLocales = ['en-US', 'en-GB']) ->
    @neutralLocale = 'en-US'
    if @knownLocales.indexOf @locale == -1
      p "locale '#{@locale}' is not in the list of known locales. using neutral locale '#{@neutralLocale}"
      @locale = @neutralLocale

  load: (callback) ->
    p "loading locale files: #{@locale}"
    count = @resx.length
    if @neutralLocale == @locale
      localeSegment = ''
    else
      localeSegment = ".#{@locale}"
    for resx in @resx
      do (resx) =>
        settings =
          url: "#{@path}#{resx}#{localeSegment}.resx"
          success: (data) =>
            @parseXML data, resx
            if --count == 0
              callback()
          dataType: 'xml'
          error: =>
            throw "failed loading resource: #{resx}#{localeSegment}.resx"
            $.get "#{@path}#{resx}.resx", (data) =>
              p 'recovered with neutral locale'
              @parseXML data, resx
              if --count == 0
                callback()
            , 'xml'
        $.ajax settings

  parseXML: (xml, propName) ->
    obj = {}
    if xml.hasChildNodes()
      root = xml.childNodes[0]
      tags = root.getElementsByTagName 'data'
      obj[tag.getAttribute 'name'] = tag.childNodes[1].childNodes[0].data for tag in tags
      @[propName] = obj
    obj

  localDate: ->
    $.datepicker.regional['en-US'] = $.datepicker.regional['']
    $.datepicker.setDefaults($.datepicker.regional[@culture]);

  replace: ($target) ->
    if $target?
      $elements = $target.find '[data-localized-string]'
    else
      $elements = $('[data-localized-string]')
    $elements.each (index, element) =>
      $element = $(element)
      localizedValue = @getLocalizedValue $element.attr 'data-localized-string'
      $element.text localizedValue
    if $target?
      $elements = $target.find '[data-localized-placeholder]'
    else
      $elements = $('[data-localized-placeholder]')
    $elements.each (index, element) =>
      $element = $(element)
      localizedValue = @getLocalizedValue $element.attr 'data-localized-placeholder'
      $element.attr 'placeholder', localizedValue
    if $target?
      $elements = $target.find '[data-localized-title]'
    else
      $elements = $('[data-localized-title]')
    $elements.each (index, element) =>
      $element = $(element)
      localizedValue = @getLocalizedValue $element.attr 'data-localized-title'
      $element.attr 'title', localizedValue
    # JRS buttons act strange because the HTML is created programatically by jquery ui
    if $target?
      $elements = $target.find '[data-localized-button]'
    else
      $elements = $('[data-localized-button]')
    $elements.each (index, element) =>
      $element = $(element)
      localizedValue = @getLocalizedValue $element.attr 'data-localized-button'
      $element.button 'option', 'label', localizedValue
    if $target?
      $elements = $target.find '[data-localized-value]'
    else
      $elements = $('[data-localized-value]')
    $elements.each (index, element) =>
      $element = $(element)
      localizedValue = @getLocalizedValue $element.attr 'data-localized-value'
      $element.val localizedValue


  getLocalizedValue: (key) ->
    localizedName = key.split('.')
    localizedValue = @[localizedName[0]][localizedName[1]]
    debug "Localized value not found for key \"#{key}\"" if !localizedValue?
    localizedValue = "!!!#{key}!!!" if !localizedValue?
    #throw "Localized value not found for key \"#{key}\"" if !localizedValue?
    localizedValue = localizedValue.replace('&', '')

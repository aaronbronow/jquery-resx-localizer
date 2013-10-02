class Application
  @locale = 'en-US'
  
  constructor: ->
    p 'Application instance created'
    
    if location.hash?
      value = location.hash.substr(1)
      @locale = value
    
    @languages = new Languages @locale
 
  init: ->
    @languages.load =>
       @languages.replace()

    @bindGlobalEvents()
    @bindNavigation()
      
  bindNavigation: ->
    $navLinks = $('nav a')
    
    $navLinks.filter(':first').on 'click', ->
      alert app.languages.Common.FirstNavigationButton
      
  bindGlobalEvents: ->
    $(window).on 'hashchange', ->
      app.onHashChanged()
      
  onHashChanged: ->
    app.locale = location.hash.substr(1)
    app.languages.locale = app.locale
    app.languages.load =>
      app.languages.replace()
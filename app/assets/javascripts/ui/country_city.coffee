CountryCity =
  country_selected: null
  city_selected: null
  country_element: null
  city_element: null
  
  _create: ->
    @place_element = $(@element).find(".place-field")
    @_attachPlaceCaller()

  _attachPlaceCaller: ->
    @place_element.tokenInput "/api/search/?w=bth&", 
      minChars: 2
      hintText: "Выберите Места"
      noResultsText: "Место не найдено"
      animateDropdown: false
      resultsLimit: 15
      tokenLimit: 5
      preventDuplicates: true
      theme: "facebook"
      onAdd: =>
        console.log "add"
      onDelete: => 
        console.log "rmv"
      onReady: =>
        $(@element).find(".token-input-list-facebook").addClass("m-wrap")
    
$.widget "ui.country_city", CountryCity
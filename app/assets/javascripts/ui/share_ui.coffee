ShareUI =  
  options:
    callback: ->
      console.log "no cb defined"
  
  _create: (opts) ->
    @place_element = $(@element).find(".share-opts")
    $(@element).find("li a").click (ev) =>
      @options.callback($(ev.target).attr("share-switch"))  
  
    
$.widget "ui.share_ui", ShareUI
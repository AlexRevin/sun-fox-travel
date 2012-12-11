PrivacyUI =  
  options:
    callback: ->
      console.log "no cb defined"
  
  _create: (opts) ->
    @place_element = $(@element).find(".privacy-opts")
    $(@element).find("li a").click (ev) =>
      @options.callback($(ev.target).attr("privacy-switch"))  
  
    
$.widget "ui.privacy_ui", PrivacyUI
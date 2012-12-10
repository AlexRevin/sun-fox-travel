window.AssetView = class AssetView extends Backbone.View
  tagName: "div"
  className: "asset-item"
  
  events: 
    "click .item-preview .destroyer a": "destroyItem"
  
  destroyItem: (ev) =>
    ev.preventDefault()
    if @model.get("visible")
      @model.destroy()
      @remove()
    @
    
  hide: (args) =>
    @$el.hide()
    
  show: (args) =>
    @$el.show()
        
  initialize: (opts) ->
    @template = _.template $("#asset-preview-template").html()
    
    @model.on "change:image",  =>
      @render()
      
    @model.on "change:visible", =>
      @visibilitySwitch @model.get("visible")
      
    @visibilitySwitch @model.get("visible")

  visibilitySwitch: (bool) =>
    if bool
      @$el.removeClass("hidden")
    else
      @$el.addClass("hidden")
    
  render: =>
    jso = @model.toJSON()
    jso.cid = @model.cid
    @$el.html @template(jso)
    @$el.find(".item-preview").parent().attr("asset-id", @model.id)
    @ 
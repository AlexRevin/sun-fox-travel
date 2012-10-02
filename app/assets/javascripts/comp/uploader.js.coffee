window.Asset = class Asset extends Backbone.Model
  idAttribute: "_id"
  urlRoot: "/assets"
  
  defaults:
    image:
      image:
        url: ""
      md_thumb:
        url: ""
      view:
        url: ""
      medium_view:
        url: ""
    visible: true
        
  initialize:  ->
    
  is_empty: =>
    @.get("image").image.url.length == 0
    
    
window.AssetCollection = class AssetCollection extends Backbone.Collection
  model: Asset
  url: "/assets"
  
window.AssetView = class AssetView extends Backbone.View
  tagName: "li"
  
  events: {
    "click .item-preview .destroyer a": "destroyItem"
  }
  
  destroyItem: (ev) =>
    ev.preventDefault()
    @model.destroy()
    @remove()
    if $("#uploaded-assets li:hidden").not(".hidden").size() > 0
      $("#uploaded-assets li:hidden").not(".hidden").first().show()
      @slider_position-=1
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
      if @model.get("visible")
        @$el.removeClass("hidden")
      else
        @$el.addClass("hidden")

  render: =>
    @$el.html @template(@model.toJSON())
    @$el.find(".item-preview").attr("asset-id", @model.id)
    @ 
  

window.UploaderView = class UploaderView extends Backbone.View
  el: "#uploader"
  
  initialize: (opts)->
    @slider_position = 0
    @step = 5
    
    @uploader_attached = false
    
    @collection = opts.collection
    
    @collection.each (asset) =>
      item_view = new AssetView {model: asset}
      $("#uploaded-assets>ul").append item_view.render().el
      
    @collection.on "add", (asset) =>
      item_view = new AssetView {model: asset}
      $("#uploaded-assets>ul").append item_view.render().el
      @setSlider()
      
    @collection.on "remove", =>
      
      
    $(".up").bind "click", @scrollerUp
    $(".down").bind "click", @scrollerDown
    @setSlider()
      
  attachUploader:  =>
    up = @$("#fileupload")
    up.fileupload({
      url: '/assets/'
      formData: {post_id: up.attr("post-id")}
      sequentialUploads: true
      dataType: 'json'
      fileInput: $ "#fileupload"
      dropZone: $ "#upload-area"

      add: (e, data) =>
        @collection.add()
        data.submit()
      send: (e, data) =>
      done: (e, data) =>
        m = @collection.find (item) ->
          img = item.is_empty()
        m.set data.result
        # $("#upload-area").height($("#upload-area").parent(".span9").height())
    })
    @uploader_attached = true
    
    
  scrollerUp:(ev) =>
    ev.preventDefault()
    console.log "#{@slider_position} + 1 < #{@step}"
    @slider_position -=@step unless @slider_position+1 < @step
    @setSlider()
    
  scrollerDown:(ev) =>
    ev.preventDefault()
    console.log "#{@collection.length} < #{@slider_position} + #{@step} + 1"
    @slider_position +=@step unless @collection.length < @slider_position + @step + 1
    @setSlider()
      
  setSlider: =>
    $("#uploaded-assets li").hide();
    $("#uploaded-assets li:lt(#{@slider_position+@step}):gt(#{@slider_position-1})").show()
    
      
  render: =>
    @attachUploader()
    @
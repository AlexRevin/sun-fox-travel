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
        
  initialize: (attrs) =>
    @set("visible", false) if attrs.included
  is_empty: =>
    @.get("image").image.url.length == 0
    
  
  
    
window.AssetCollection = class AssetCollection extends Backbone.Collection
  model: Asset
  url: "/assets"
  
  
  
window.AssetView = class AssetView extends Backbone.View
  tagName: "div"
  className: "asset-item"
  
  events: {
    "click .item-preview .destroyer a": "destroyItem"
  }
  
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
      opt = @model.get("_id")
      el = $(".item-preview[asset-id=#{opt}]")
      if @model.get("visible")
        el.removeClass("hidden")
      else
        el.addClass("hidden")

  render: =>
    jso = @model.toJSON()
    jso.cid = @model.cid
    @$el.html @template(jso)
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
      el = item_view.render().el
      $(".asset-container").append el
      
    @collection.on "add", (asset) =>
      item_view = new AssetView {model: asset}
      el = item_view.render().el
      $(".asset-container").append el
      
    @collection.on "remove", =>
      
  attachUploader:  =>
    up = @$("#fileupload")
    up.fileupload({
      url: '/assets/'
      formData: {post_id: up.attr("post-id")}
      sequentialUploads: true
      dataType: 'json'
      fileInput: $ "#fileupload"
      dropZone: $ "#upload-area"
      progress: (e, data) =>
        prc = parseInt(data.loaded / data.total * 100, 10)
        $("[data-model-cid=#{data.context}] > span").html("#{prc} %")
      add: (e, data) =>
        @collection.add()
        data.context = @collection.last().cid
        data.submit()
      send: (e, data) =>
      done: (e, data) =>
        m = @collection.find (item) ->
          img = item.is_empty()
        m.set data.result
    })
    @uploader_attached = true
      
  render: =>
    @attachUploader()
    @
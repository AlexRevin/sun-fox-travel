# Backbone.sync = (method, model) =>
#   console.log model
#   model.id = 1

window.Item = class Item extends Backbone.Model
  idAttribute: "_id"
  url: =>
    return "post_items/#{@get('_id')}" if @get("_id")?
    return "post_items/"
  defaults:
    pos: 0
    _id: null
    asset_model: null
    text: ""
    viewport: "v-big"
    asset_id: null
  
  prefill_asset: (col) =>
    aid = @get "asset_id"
    am = @get "asset_model"
    fnd =  col.find (ci) =>
      ci.id == aid
    if fnd?
      @set "asset_model", fnd
      fnd.set "visible", false
     
     
      
window.EditorElement = class EditorElement extends Backbone.View
  tagName: "div"
  events: {
    "click .ctrl a.destroyer": "destroyItem"
    "blur textarea" : "flushText"
  }
  
  destroyItem: (ev) =>
    ev.preventDefault()
    am = @model.get("asset_model")
    if am?
      am.set "visible", true
    @model.destroy()
    @remove()
    
  initialize: (opts) =>
    parent = opts.parent
    @template =_.template $("#editor-item-tpl").html()
    @model.on "change:viewport", @light_render
    @model.on "change:_id", @light_render
    
  light_render: (caller) =>
    a = JSON.parse(JSON.stringify(@model.toJSON()))
    @$el.html(@template(a))
    @$el.attr "id", @model.get("_id") || null
    @$el.addClass("sorter")
    setTimeout =>
      @$el.find("textarea").autosize();
    200
    @
    
  render: =>
    a = JSON.parse(JSON.stringify(@model.toJSON()))
    @$el.html(@template(a))
    setTimeout =>
      @$el.find("textarea").focus().autosize();
      $('html, body').animate
        scrollTop: @$el.find("textarea").offset().top
      2000
    20
    @
    
  flushText: (ev) =>
    ev.preventDefault()
    el = $ ev.target
    @model.set "text", el.val()
    @model.save(["asset_id", "text"],
      success: (model, resp) =>
        model.set("_id", resp._id)
    )
    
    
    
window.ItemCollection = class ItemCollection extends Backbone.Collection
  model: Item
  url: ->
    "/posts/#{@post_id}/"
    
  setPostId: (post_id) =>
    @post_id = post_id
    window.post_id = post_id
  
  
window.EditorView = class EditorView extends Backbone.View
  el: "#editor"
  
  initialize: (opts) =>
    @position_counter = 0
    @asset_collection = opts.asset_collection
    @item_collection = opts.item_collection
    @size = $.cookie("viewport.image-size") || "v-big"
    
    @$el.sortable
      forcePlaceholderSize: true
      axis: "y"
      scroll: true
      items: "> .sorter"
      tolerance: "pointer"
      receive: (evt, ui) =>
        @createElement $(ui.item).find(".item-preview").attr("asset-id")  
        @sortableCallback()
      start: (evt, ui) =>
        $(".text-editor").hide()
      stop: (evt, ui) =>
        $(".text-editor").show()
      update: (evt, ui) =>
        @sortableCallback()
        
    $("#uploaded-assets .asset-item").live 'mouseover', ->
      $(this).draggable({
        revert: true
        containment: 'window'
        scroll: false
        helper: 'clone'
        connectToSortable: "#editor"
      })
        
    @item_collection.each (item) =>
      item.prefill_asset @asset_collection
      item.set "viewport", @size
      if item.has("image") || item.has("asset_id")
        e_elem = new EditorElement {model: item, parent: @}
        $("#editor .placeholder").before e_elem.light_render().el
    
    @item_collection.on "add", (item) =>
      item.save ["asset_id", "text"]
      e_elem = new EditorElement {model: item, parent: @}
      $("#editor .placeholder").before e_elem.render().el
    
    
    @attachViewPortControl()
    
  postsUrl: =>
    "/posts/#{window.post_id}"
    
  sortableCallback: =>
    $.ajax "#{@postsUrl()}/update_positions/",
      type: "POST",
      data: 
        positions: @$el.sortable('toArray')
          
  attachViewPortControl: =>
    $(".viewport a").bind "click", (ev) =>
      switch $(ev.target).attr("viewport-class")
        when "zoom"
          @size = "v-#{$(ev.target).attr("image-size")}"
          $.cookie("viewport.image-size", @size)
          @item_collection.each (m) =>
            m.set("viewport", @size)
        when "fullscreen"
          $("#editor").fullScreen(true)
      ev.preventDefault()
      
    $("#save_post").bind "click", (evt) =>
      @item_collection.each (x) =>
        x.save ["asset_id", "text"], 
          success: (model, response) =>
          error: (model, response) =>
      evt.preventDefault()
    
        
  createElement: (item_id) =>
    found = @asset_collection.find (item) =>
      item.id == item_id
    if found? && found.has("image")?
      found.set("visible", false)
      @item_collection.add({asset_model: found, viewport: @size, asset_id: item_id}, pos: (@position_counter+=1))
    else
    
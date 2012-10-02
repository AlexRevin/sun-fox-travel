window.Item = class Item extends Backbone.Model
  defaults:
    asset_model: null
    text: ""
    viewport: "big"

window.EditorElement = class EditorElement extends Backbone.View
  tagName: "div"
  events: {
    "click .ctrl a.destroyer": "destroyItem"
    "blur textarea" : "flushText"
  }
  
  destroyItem: (ev) =>
    ev.preventDefault()
    @model.get("asset_model").set("visible", true)
    @model.destroy()
    @remove()
    
  
  initialize: (opts) =>
    parent = opts.parent
    @template =_.template $("#editor-item-tpl").html()
    @model.on "change:viewport", @render
    
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
    
window.ItemCollection = class ItemCollection extends Backbone.Collection
  model: Item
  
window.EditorView = class EditorView extends Backbone.View
  el: "#editor"
  
  initialize: (opts) =>
    @asset_collection = opts.asset_collection
    @item_collection = opts.item_collection
    @size = "big"
    
    $("#uploaded-assets li").live 'mouseover', ->
      $(this).draggable({revert: true})

    @$el.droppable {
      drop: (evt, ui) =>
        @createElement $(evt.srcElement).attr("asset-id")
      activate: (evt, ui) =>
      accept: ".ui-draggable"
      greedy: true
    }
    
    @item_collection.each (item) =>
      e_elem = new EditorElement {model: item, parent: @}
      $("#editor .placeholder").before e_elem.render().el
    
    @item_collection.on "add", (item) =>
      e_elem = new EditorElement {model: item, parent: @}
      $("#editor .placeholder").before e_elem.render().el
    
    
    $(".viewport a").bind "click", (ev) =>
      switch $(ev.target).attr("viewport-class")
        when "zoom"
          @size = $(ev.target).attr("image-size")
          @item_collection.each (m) =>
            m.set("viewport", @size)
        when "fullscreen"
          $("#editor").fullScreen(true)
      ev.preventDefault()
        
  createElement: (item_id) =>
    found = @asset_collection.find (item) =>
      item.id == item_id
    if found?
      found.set("visible", false)
      @item_collection.add({asset_model: found, viewport: @size})
    else
    
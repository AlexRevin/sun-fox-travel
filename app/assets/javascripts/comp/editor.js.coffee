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
    cover: false
    private: false
  
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
    "click .edit-placeholder a" : "menuAction"
  }
  
  destroyItem: (ev) =>
    ev.preventDefault()
    am = @model.get("asset_model")
    if am?
      am.set "visible", true
    @model.destroy()
    @$el.parent(".ui-draggable").detach()
    @remove()
    
  initialize: (opts) =>
    parent = opts.parent
    @template =_.template $("#editor-item-tpl").html()
    @model.on "change:viewport", @light_render
    @model.on "change:_id", @light_render
    
  light_render: (caller) =>
    a = JSON.parse(JSON.stringify(@model.toJSON()))
    @$el.html(@template(a))
    @$el.attr "item-id", @model.get("_id") || null
    @$el.addClass("sorter")
    setTimeout =>
      @$el.find("textarea").autosize();
    200
    @
    
  menuAction: (ev) =>
    ev.preventDefault()
    switch $(ev.target).attr "viewport-class"
      when "cover"
        $("[viewport-class='cover']").removeClass "purple"
        @model.collection.map (x) =>
          x.set "cover", false
        @model.set("cover", true)
        $(ev.target).addClass "purple"
        
        @model.set("private", false)
        $(ev.target).next().removeClass "green"
        
      when "private"
        console.log @model.get("cover")
        unless @model.get("cover")
          unless @model.get("private")
            @model.set("private", true)
            $(ev.target).addClass "green"
          else
            @model.set("private", false)
            $(ev.target).removeClass "green"
        else
          return
    @model.save()
    
  render: =>
    a = JSON.parse(JSON.stringify(@model.toJSON()))
    @$el.html(@template(a))
    @$el.attr "item-id", @model.get("_id") || null
    @$el.addClass("sorter")
    @
    
  flushText: (ev) =>
    ev.preventDefault()
    el = $ ev.target
    @model.set "text", el.val()
    # @loadingIcon("on")
    @model.save(["asset_id", "text"],
      success: (model, resp) =>
        # @loadingIcon("off")
        model.set("_id", resp._id)
    )
  loadingIcon: (state) => 
    if state=="on"
      @$el.find(".loading-placeholder").addClass("loading")
    else
      @$el.find(".loading-placeholder").removeClass("loading")
    
    
    
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

    @asset_collection = opts.asset_collection
    @item_collection = opts.item_collection
    @size = $.cookie("viewport.image-size") || "v-big"
    
    @pos = 0
    
    @$el.sortable
      forcePlaceholderSize: true
      forceHelperSize: true
      containment: @$el
      axis: "y"
      # delay: 200
      scroll: true
      items: "> .asset-item"
      change: (evt, ui) =>
        ui.item.data "pos", $(ui.placeholder).index()

      receive: (evt, ui) =>

      activate: (evt, ui) =>
        $(".text-editor").hide()
        h = $(ui.item).height() - 40
        $(".placeholder-v-small, .placeholder-v-big").css("height", h)
      deactivate: (evt, ui) =>
        $(".text-editor").show()
        
      update: (evt, ui) =>
        asset_id = $(ui.item).attr("asset-id")
        pos = ui.item.data("pos")
        found = @item_collection.find (i, c) =>
          i.get("asset_id") == asset_id
        unless found?
          $(ui.item).find(".item-preview").detach()
          @createElement asset_id, pos
        else
          found.set "pos", pos
        @sortableCallback()
        
    @sortableOpt "placeholder", "placeholder-#{@size}"
    
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
      if item? && (item.has("image") || item.has("asset_id"))
        e_elem = new EditorElement {model: item, parent: @}
        
        el = e_elem.light_render().el
        $(el).attr "item-id", item.get("_id")
        
        div = $("<div class=\"asset-item ui-draggable\"></div>")
        div.append el
        $("#editor .placeholder").before(div)
    
    @item_collection.on "add", (item) =>
      item.save ["asset_id", "text"],        
        wait: true
        success: (model, resp) =>
          @sortableCallback()
        
      e_elem = new EditorElement {model: item, parent: @}
      
      el = e_elem.render().el
      $(el).attr "item-id", item.cid
      
      to_el = @$el.find(".asset-item[asset-id=#{item.get("asset_id")}]")
      to_el.prepend el
      
      @setTextarea to_el
      
      @$el.sortable('refresh')
    
    @attachViewPortControl()
    
  setTextarea: (e) =>
    setTimeout =>
      e.find("textarea").focus().autosize();
      $('html, body').animate
        scrollTop: e.find("textarea").offset().top
      2000
    2000
    
  createElement: (item_id, pos) =>
    found = @asset_collection.find (item) =>
      item.id == item_id
    if found? && found.has("image")?
      found.set("visible", false)
      @item_collection.add({asset_model: found, viewport: @size, asset_id: item_id, pos: pos})
      
  
  postsUrl: =>
    "/posts/#{window.post_id}"
    
  sortableCallback: =>
    @$el.sortable('refresh')
    @$el.sortable('refreshPositions')
    a = _.map @$el.find(".ui-draggable .sorter"), (x) =>
      $(x).attr("item-id")
      
    $.ajax "#{@postsUrl()}/update_positions/",
      type: "POST",
      data: 
        positions: a
        
  sortableOpt: (name, value) =>
    @$el.sortable("option", name, value)
          
  attachViewPortControl: =>
    $(".viewport a").bind "click", (ev) =>
      switch $(ev.target).attr("viewport-class")
        when "zoom"
          @size = "v-#{$(ev.target).attr("image-size")}"
          $.cookie("viewport.image-size", @size)
          @item_collection.each (m) =>
            m.set("viewport", @size)
          @sortableOpt "placeholder", "placeholder-#{@size}"
        when "fullscreen"
          $("#editor").fullScreen(true)
      ev.preventDefault()
      
    $("#save_post").bind "click", (evt) =>
      @item_collection.each (x) =>
        x.save ["asset_id", "text"], 
          success: (model, response) =>
          error: (model, response) =>
      evt.preventDefault()
    
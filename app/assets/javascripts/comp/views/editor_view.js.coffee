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
        $("#editor").append(div)
    
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
    $('html, body').animate({
      scroll: e.find("textarea").offset().top
    }, 1000, ->
      e.find("textarea").focus().autosize()
    )
    
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
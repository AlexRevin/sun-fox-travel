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
    am.set "visible", true if am?
    @model.destroy()
    @$el.parent(".ui-draggable").detach()
    @remove()
    
  initialize: (opts) =>
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

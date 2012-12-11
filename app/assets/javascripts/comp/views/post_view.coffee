window.PostView = class PostView extends Backbone.View
  el: "#post-viewer"
  
  initialize: (opts) =>
    @item_collection = opts.item_collection
    @asset_collection = opts.asset_collection

    @item_collection.each (i) =>
      i.prefill_asset(@asset_collection)
      
    @view_modes=
      bbcode:
        inner_tpl: _.template $("#viewer-item-bbcode-tpl").html()
      html_item:
        inner_tpl: _.template $("#viewer-item-html-tpl").html()
      html_post:
        outer_tpl: _.template $("#viewer-post-html-container-tpl").html()
        inner_tpl: _.template $("#viewer-post-html-tpl").html()
        
        
    @mode = null
    @privacy_mode = null

  share_ui_listener: (meth) =>
    @mode = meth
    @$el.empty()
    @render()
  privacy_ui_listener: (meth) =>
    @privacy_mode = meth
    @$el.empty()
    @render()
    
  render: ->
    switch @mode
      when "html_post"
        @$el.html( @view_modes[@mode].outer_tpl)
        _.each @_appender(@mode), (i) =>
          @$el.find("textarea").append $(i).html()
        @$el.find("textarea").autosize()
      else
        _.each @_appender(@mode), (i) =>
          @$el.append i
          
  _appender: (mode) ->
    views = @_collection().map (item) =>
      e_elem = new PostElement {model: item, parent: @, mode: @view_modes[mode] }
      el = e_elem.render().el
    views
    
  _collection: ->
    switch @privacy_mode
      when "public"
        return @item_collection.filter (i) ->
          !i.get("private")
      when "private"
        return @item_collection.filter (i) ->
          i.get("private")
      else
        @item_collection

window.PostView = class PostView extends Backbone.View
  el: "#post-viewer"
  
  initialize: (opts) =>
    @item_collection = opts.item_collection
    @asset_collection = opts.asset_collection
    @item_collection.each (i) =>
      i.prefill_asset(@asset_collection)

  render: ->
    @item_collection.each (item) =>
      e_elem = new PostElement {model: item, parent: @}
      el = e_elem.render().el
      @$el.append(el)
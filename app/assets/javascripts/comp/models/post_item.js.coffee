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
    text_html: ""
  
  prefill_asset: (col) =>
    aid = @get "asset_id"
    am = @get "asset_model"
    fnd =  col.find (ci) =>
      ci.id == aid
    if fnd?
      @set "asset_model", fnd
      fnd.set "visible", false

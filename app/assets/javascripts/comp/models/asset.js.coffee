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

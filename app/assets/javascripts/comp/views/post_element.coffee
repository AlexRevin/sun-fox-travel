window.PostElement = class PostElement extends Backbone.View
  tagName: "div"
  
  initialize: (opts) =>
    # @template =_.template $("").html()
    
    @template = opts.mode?.inner_tpl ? _.template $("#viewer-item-tpl").html()
    
  render: =>
    a = JSON.parse(JSON.stringify(@model.toJSON()))
    @$el.html(@template(a))
    @
    
    
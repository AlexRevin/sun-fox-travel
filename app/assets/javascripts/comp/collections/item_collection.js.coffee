window.ItemCollection = class ItemCollection extends Backbone.Collection
  model: Item
  url: ->
    "/posts/#{@post_id}/"
    
  setPostId: (post_id) =>
    @post_id = post_id
    window.post_id = post_id
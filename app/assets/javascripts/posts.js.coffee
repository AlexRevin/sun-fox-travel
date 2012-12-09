$(document).ready (args) ->
  
  window.asset_collection = new AssetCollection
  if existing_asset_collection?
    existing_asset_collection.each (x) ->
      window.asset_collection.unshift x
  window.upload_box = new window.UploaderView({
    collection: window.asset_collection
  })
  window.upload_box.render()


  window.item_collection = new ItemCollection
  if existing_item_collection?
    existing_item_collection.each (x) ->
      window.item_collection.unshift x
      
  window.editor_box = new window.EditorView({
    item_collection: window.item_collection
    asset_collection: window.asset_collection
  })
  window.editor_box.render()
  
  window.post_box = new window.EditorPostView({
    title_elem: $(".post-title")
    title_button: $(".post-title-button")
  })
$(document).ready (args) ->
  
  asset_collection = new AssetCollection
  if existing_asset_collection?
    existing_asset_collection.each (x) ->
      asset_collection.unshift x
  upload_box = new window.UploaderView({
    collection: asset_collection
  })
  upload_box.render()


  item_collection = new ItemCollection
  if existing_item_collection?
    existing_item_collection.each (x) ->
      item_collection.unshift x
      
  editor_box = new window.EditorView({
    item_collection: item_collection
    asset_collection: asset_collection
    upload_box: upload_box
  })
  editor_box.render()
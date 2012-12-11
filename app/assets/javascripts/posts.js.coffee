$(document).ready (args) ->
  $('.country-city').country_city()
  
  window.asset_collection = new AssetCollection
  window.item_collection = new ItemCollection
  
  if existing_asset_collection?
    existing_asset_collection.each (x) ->
      window.asset_collection.unshift x
      
  if existing_item_collection?
    existing_item_collection.each (x) ->
      window.item_collection.unshift x

  unless $("#uploader").length == 0
    window.upload_box = new window.UploaderView
      collection: window.asset_collection
    window.upload_box.render()

  unless $("#editor").length == 0
    window.editor_box = new window.EditorView
      item_collection: window.item_collection
      asset_collection: window.asset_collection
    window.editor_box.render()
  
    window.post_box = new window.EditorPostView
      title_elem: $(".post-title")
      title_button: $(".post-title-button")
      
  unless $("#post-viewer").length == 0
    window.post_viewer = new window.PostView
      item_collection: window.item_collection
      asset_collection: window.asset_collection
    window.post_viewer.render()
    
    $(".share-opts").share_ui({
     callback: window.post_viewer.share_ui_listener
    })
    $(".privacy-opts").privacy_ui
      callback: window.post_viewer.privacy_ui_listener
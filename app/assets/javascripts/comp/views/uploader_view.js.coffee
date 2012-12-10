window.UploaderView = class UploaderView extends Backbone.View
  el: "#uploader"
  
  initialize: (opts)->
    @uploader_attached = false
    
    @collection = opts.collection
    
    @collection.each (asset) =>
      item_view = new AssetView {model: asset}
      el = item_view.render().el
      $(".asset-container").append el
      
    @collection.on "add", (asset) =>
      item_view = new AssetView {model: asset}
      el = item_view.render().el
      $(".asset-container").append el
      
    @collection.on "remove", =>
    
    $(window).on 'resize', @windowResized
      
  windowResized: =>
    h = $(window).height() - $("#uploader").height() - $("#uploaded-assets .title").height()-60
    $(".asset-container").height(h)
      
  attachUploader:  =>
    up = @$("#fileupload")
    console.log up.attr("post-id")
    up.fileupload({
      url: "/assets/?post_id=#{up.attr("post-id")}"
      sequentialUploads: true
      dataType: 'json'
      fileInput: $ "#fileupload"
      dropZone: $ "#upload-area"
      progress: (e, data) =>
        prc = parseInt(data.loaded / data.total * 100, 10)
        $("[data-model-cid=#{data.context}] > span").html("#{prc} %")
      add: (e, data) =>
        @collection.add()
        data.context = @collection.last().cid
        data.submit()
      send: (e, data) =>
      done: (e, data) =>
        m = @collection.find (item) ->
          img = item.is_empty()
        m.set data.result
    })
    @uploader_attached = true
    
  remove: =>
    $(window).off('resize', @windowResized)
      
  render: =>
    @attachUploader()
    @windowResized()
    @
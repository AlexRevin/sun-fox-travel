window.EditorPostView = class EditorPostView extends Backbone.View
  initialize: (opts) ->
    @title_elem = opts.title_elem
    @clicker = opts.title_button
    @model = new window.Post
      _id: $(".post-opts").attr("post-id")
    @model.sync
    @clicker.click (ev) =>
      @model.set("title", @title_elem.val())
      @model.save ["title"],
        success: (model, resp) =>
          console.log "saved"
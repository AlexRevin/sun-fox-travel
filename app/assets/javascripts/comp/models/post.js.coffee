window.Post = class Post extends Backbone.Model
  idAttribute: "_id"
  urlRoot: "/posts"
  defaults:     
    title: ""
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
_.templateSettings = 
  interpolate: /\{\{(.+?)\}\}/g,
  escape: /\{\{- (.+?)\}\}/g,
  evaluate: /\[\[(.+?)\]\]/g
  

$(document).ready (args) ->
  
  $('.search-reviews').country_city()
  
  $('.search-reviews ul').tooltip("show")
  
  $(".wizard-starter").tooltip({
    trigger: "manual"
  })
  $(".wizard-starter").tooltip("show")
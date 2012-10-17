# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
_.templateSettings = 
  interpolate: /\{\{(.+?)\}\}/g,
  escape: /\{\{- (.+?)\}\}/g,
  evaluate: /\[\[(.+?)\]\]/g
  

$(document).ready (args) ->
  
  $('.country-city').country_city()
  $("img.lazy").lazyload
    threshold: 500
    effect: "fadeIn"
  
  
  $('.search-input').tooltip("show")
  
  $(".image-of-the-day img").imagesLoaded (args) ->

    $(".image-of-the-day img").popover({
      content: $(".text-of-the-day").html()
      title: $(".text-of-the-day-title").html()
      trigger: "manual"
    })
    $(".image-of-the-day img").popover("show")
  
  $(".search-input").typeahead({
    minLength: 2
    source: (query, th) ->
      $.ajax "/api/search"
        dataType: "json"
        type: "GET"
        data:
          w: "bth" 
          q: query 
        success: (res) ->
          th(res)    
  })
  $(".wizard-starter").tooltip({
    trigger: "manual"
  })
  $(".wizard-starter").tooltip("show")
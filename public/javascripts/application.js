// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$("#big-search-box").bind("keyup", function() {
  $("#big-search-box").addClass("loading"); // show the spinner
  var form = $("#live-search-form"); // grab the form wrapping the search bar.
  var url = "/videos/search"; // live_search action.  
  var formData = form.serialize(); // grab the data in the form  
  $.get(url, formData, function(html) { // perform an AJAX get
    $("#big-search-box").removeClass("loading"); // hide the spinner
    $("#videos").html(html); // replace the "results" div with the results
  });
}); 

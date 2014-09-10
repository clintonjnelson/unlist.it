//////////////////////// SEARCH PAGE /////////////////////////
//Hide Modal via Form Button Click
$(document).on("click", ".modal-close", function() {
  $(".modal.in").modal('hide');
});

//Infinite Scrolling
$(document).on('ready, page:change', function(){
  var loading_stuff = false;
  $('a.infinite-load-post').on('inview', function(e, visible){
    if(loading_stuff || !visible) {
      return;
    }
    loading_stuff = true;
    $.ajax({
      url: $(this).attr('href'),
      method: "post",
      dataType: "script"
    });
    loading_stuff = false;
  });
});


//////////////////////// ADD UNLISTING /////////////////////////
//Toggle the Hide or Show for radio button selection of Linked URL Thumbs
$(document).on("click", "#image_links_use_thumb_image", function() {
  $('#link-image-thumbs').toggleClass("hide");
});



//////////////////////// UNLISTING RESPONSE /////////////////////////
//Infinite Scrolling
$(document).on('ready, page:change', function(){
  var loading_stuff = false;
  $('a.infinite-load').on('inview', function(e, visible){
    if(loading_stuff || !visible) {
      return;
    }
    loading_stuff = true;
    $.getScript($(this).attr('href'), function(){
      loading_stuff = false;
    });
  });
});


//Tabbed interface for Unlistings display
$(function() {
  $("#tabs").tabs();
});

//New Message checkbox activation of the submit button with AJAX Listener
$(document).ready( function() {
  $("#check1,#check2,#check3").on('change', function() {
    if ($('#check1:checked,#check2:checked,#check3:checked').length == 3)
      $('#sendmessage').removeAttr('disabled');
    else
      $('#sendmessage').attr('disabled', 'disabled');
  });
});

//Hide or show the Unlisting First Response messages & replies in Unlistings section
$(document).ready(function() {
  $(".hideshow-response").on("click", function() {
    $(this).parent().find('ul').toggleClass("hide")
  });
});

//Hide or show the Replies on messages in the User's Messages section
$(document).ready(function() {
  $(".hideshow-replies").on("click", function() {
    $(this).parents('.reply-form-listener').find('.replies').toggleClass("hide")
  });
});

//Show replies (Used with Unlist pages & Messages pages)
$(document).ready(function() {
  $(".reply-form-show").on("click", function() {
    var _this = this;
    var repliesClass = $(_this).parents('.reply-form-listener').find('.replies')

    //If replies are turned off, turn them on for visibility during
    if (repliesClass[0] && repliesClass.hasClass("hide")) {
      repliesClass.removeClass("hide");
    };
    $(_this).parents('.reply-form-listener').find('.reply-form').toggleClass("hide");
    $(_this).remove();
  });
});


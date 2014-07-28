
//////////////////////// UNPOST RESPONSE /////////////////////////
//Tabbed interface for Unposts display
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

//Hide or show the Unpost First Response messages & replies in Unposts section
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



///JS FOR ADDING THE BLUEIMP LIGHTBOX - **DONT DELETE** IT WORKS for future use
// $(document).ready(function() {
//   $("#links").on("click", function (event) {
//     event = event || window.event;
//     var target = event.target || event.srcElement,
//       link     = target.src ? target.parentNode : target,
//       options  = {index: link, event: event},
//       links    = this.getElementsByTagName('a');
//     blueimp.Gallery(links, options);
//   });
// });


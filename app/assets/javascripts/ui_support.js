
//////////////////////// UNPOST RESPONSE /////////////////////////
//Tabbed interface for Unposts display
$(function() {
  $("#tabs").tabs();
});

//New Message checkbox activation of the submit button with AJAX Listener
$(document).ready( function() {
  $("#check1,#check2,#check3,#check4,#check5").on('change', function() {
    if ($('#check1:checked,#check2:checked,#check3:checked,#check4:checked,#check5:checked').length == 5)
      $('#sendmessage').removeAttr('disabled');
    else
      $('#sendmessage').attr('disabled', 'disabled');
  });
});

//Hide or show the Unpost Messages for an Unpost with Hits
$(document).ready(function() {
  $(".hideshow-response").on("click", function() {
    $(this).parent().find('ul').toggleClass("hide")
  });
});

//Galleria Setup File for Loading
// $(document).ready(function() {
//   if ($('.galleria').length == 1) {
//     Galleria.loadTheme('assets/javascripts/galleria.classic.min.js');
//     Galleria.configure({
//       debug: false,
//       imageCrop: true,
//       //dummy: 'app/assets/images/',
//       trandition: 'fade'
//     });
//     Galleria.run('.galleria');
//   };
// });


///JS FOR ADDING THE BLUEIMP LIGHTBOX - WORKS!!!
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




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

// $(document).ready(function($) {
//   var gallery = $('#thumbs').galleriffic({
//     delay:                     3000, // in milliseconds
//     numThumbs:                 6, // The number of thumbnails to show page
//     preloadAhead:              40, // Set to -1 to preload all images
//     enableTopPager:            false,
//     enableBottomPager:         true,
//     maxPagesToShow:            7,  // The maximum number of pages to display in either the top or bottom pager
//     imageContainerSel:         '', // The CSS selector for the element within which the main slideshow image should be rendered
//     controlsContainerSel:      '', // The CSS selector for the element within which the slideshow controls should be rendered
//     captionContainerSel:       '', // The CSS selector for the element within which the captions should be rendered
//     loadingContainerSel:       '', // The CSS selector for the element within which should be shown when an image is loading
//     renderSSControls:          true, // Specifies whether the slideshow's Play and Pause links should be rendered
//     renderNavControls:         true, // Specifies whether the slideshow's Next and Previous links should be rendered
//     playLinkText:              'Play',
//     pauseLinkText:             'Pause',
//     prevLinkText:              'Previous',
//     nextLinkText:              'Next',
//     nextPageLinkText:          'Next &rsaquo;',
//     prevPageLinkText:          '&lsaquo; Prev',
//     enableHistory:             false, // Specifies whether the url's hash and the browser's history cache should update when the current slideshow image changes
//     enableKeyboardNavigation:  true, // Specifies whether keyboard navigation is enabled
//     autoStart:                 false, // Specifies whether the slideshow should be playing or paused when the page first loads
//     syncTransitions:           false, // Specifies whether the out and in transitions occur simultaneously or distinctly
//     defaultTransitionDuration: 1000, // If using the default transitions, specifies the duration of the transitions
//     onSlideChange:             undefined, // accepts a delegate like such: function(prevIndex, nextIndex) { ... }
//     onTransitionOut:           undefined, // accepts a delegate like such: function(slide, caption, isSync, callback) { ... }
//     onTransitionIn:            undefined, // accepts a delegate like such: function(slide, caption, isSync) { ... }
//     onPageTransitionOut:       undefined, // accepts a delegate like such: function(callback) { ... }
//     onPageTransitionIn:        undefined, // accepts a delegate like such: function() { ... }
//     onImageAdded:              undefined, // accepts a delegate like such: function(imageData, $li) { ... }
//     onImageRemoved:            undefined  // accepts a delegate like such: function(imageData, $li) { ... }
//   });
// });

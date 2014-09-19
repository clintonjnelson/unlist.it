//VARIOUS AJAX FORM CALLS


//////////////////////// ADD UNLISTING /////////////////////////
//Load the Website Thumbnails of provided URL (limited to 5 per configs)
$(document).ready(function() {
  $(".link-thumbnails-input").on("change", function() {
    $.ajax({
      type: "POST",
      url: "/show_thumbnails",
      dataType: "script",
      data: {
              thumb_url:      $(this).val(),
              unlisting_slug: $('.link-thumbnails').data('id')
            }
    });
    return false;
  });
});

//Ajax population of the links if the website is already loaded
//TODO: ADD SHOWING OF THE IMAGES IF THE UNLISTING LINK IMAGE USE IS SELECTED
$(document).ready(function() {
  if($(".link-thumbnails-input").length > 0) {
    var _this = ".link-thumbnails-input"
    $.ajax({
      type: "POST",
      url: "/show_thumbnails",
      dataType: "script",
      data: {
              thumb_url:      $(_this).val(),
              unlisting_slug: $('.link-thumbnails').data('id')
            }   //Load directly due to if statement
    });
    return false;
  };
});






//Ajax Population of ConditionSelect For Selected Category
$(document).ready(function() {
  $(".unlisting_category_select").on("select change", function() {
    $.ajax({
      type: "POST",
      url: "/conditions_by_category",
      dataType: "script",
      data: {category_id: $(this).val()}
    });
    return false;
  });
});

//Ajax Population of ConditionSelect For Selected Category on LOAD
$(document).ready(function() {
  if($(".unlisting_category_select").length > 0) {
    $.ajax({
      type: "POST",
      url: "/conditions_by_category",
      dataType: "script",
      data: {category_id: $(".unlisting_category_select").val()}
    });
    return false;
  }
});

//Ajax deletion of Unimages
$(document).ready(function(){
  $('.remove-unimage').on('click', function(e){
    var _this = this;
    e.preventDefault();
    e.stopPropagation();
    var unimageId       = $(_this).parent().find('[name="unimage[id]"]').val();
    var unimageToken    = $(_this).parent().find('[name="unimage[token]"]').val();
    var unimageFilename = $(_this).parent().find('[name="unimage[filename]"]').val();
    $.ajax({
      url: '/remove_unimage',
      type: 'DELETE',
      dataType: 'script',
      data: {
        unimage: {
          id: unimageId,
          token: unimageToken,
          filename: unimageFilename
        }
      }
    });
    false
    $(_this).parent().remove();
  });
});


//////////////////////// ADD CONDITION /////////////////////////
//Ajax Population of ConditionSelect For Selected Category on CHANGE
$(document).ready(function() {
  $(".add-condition-category-select").on("change", function() {
    $.ajax({
      type: "POST",
      url: "/admin/conditions_by_category",
      dataType: "script",
      data: {category_id: $(this).val()}
    });
    return false;
  });
});

//Ajax Population of ConditionSelect For Selected Category on LOAD
$(document).ready(function() {
  if($(".add-condition-category-select").length > 0) {
    $.ajax({
      type: "POST",
      url: "/admin/conditions_by_category",
      dataType: "script",
      data: {category_id: $(".add-condition-category-select").val()}
    });
    return false;
  }
});













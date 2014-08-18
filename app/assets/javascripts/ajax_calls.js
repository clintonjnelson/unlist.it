//VARIOUS AJAX FORM CALLS


//////////////////////// ADD UNLISTING /////////////////////////
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
//MAY NEED A if ($(".add-condition-category-select").length == 1) { //do stuff below// }
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
//MAY NEED A if ($(".add-condition-category-select").length == 1) { //do stuff below// }
$(document).ready(function() {
  if($(".unlisting_category_select").length > 0) {
    $.ajax({
      type: "POST",
      url: "/admin/conditions_by_category",
      dataType: "script",
      data: {category_id: $(".add-condition-category-select").val()}
    });
    return false;
  }
});













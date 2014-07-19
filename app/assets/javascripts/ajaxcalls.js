//VARIOUS AJAX FORM CALLS


//////////////////////// ADD UNPOST /////////////////////////
//Ajax Population of ConditionSelect For Selected Category
$(document).ready(function() {
  $(".unpost_category_select").on("select change", function() {
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
  $.ajax({
    type: "POST",
    url: "/conditions_by_category",
    dataType: "script",
    data: {category_id: $(".unpost_category_select").val()}
  });
  return false;
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
  $.ajax({
    type: "POST",
    url: "/admin/conditions_by_category",
    dataType: "script",
    data: {category_id: $(".add-condition-category-select").val()}
  });
  return false;
});













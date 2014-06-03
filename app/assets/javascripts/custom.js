
//Ajax Population of ConditionSelect For Selected Category
$(document).ready(function() {
  $(".unpost_category_select").on("change", function() {
    $.ajax({
      type: "POST",
      url: "/conditions_by_category",
      dataType: "script",
      data: {category_id: $(this).val()}
    });
    return false;
  });
});

//Ajax Population of ConditionSelect For Selected Category
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

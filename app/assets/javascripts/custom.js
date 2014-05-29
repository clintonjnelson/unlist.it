
//Ajax Population of ConditionSelect For Selected Category
$(document).ready(function() {
  $(".unpost_category_select").on("change", function() {
    $.ajax({
      type: "POST",
      url: "/conditions_by_category",
      dataType: "script",
      data: {param1: $(this).val()}
    });
    return false;
  });
});

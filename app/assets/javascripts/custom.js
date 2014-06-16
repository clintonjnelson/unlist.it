
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


//Checkbox activation of the submit button with AJAX Listener
$(document).ajaxComplete(function() {
  $("#check1,#check2,#check3,#check4,#check5,#message_content").on('change', function() {
    if (($('#check1:checked,#check2:checked,#check3:checked,#check4:checked,#check5:checked').length == 5) && ($('#message_content').val().length > 0))
      $('#sendmessage').removeAttr('disabled');
    else
      $('#sendmessage').attr('disabled', 'disabled');
  });
});

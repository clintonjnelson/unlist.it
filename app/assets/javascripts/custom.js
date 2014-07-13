
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



//////////////////////// UNPOST RESPONSE /////////////////////////
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
    $(this).parent().find('ul').toggleClass('hide')
  });
});









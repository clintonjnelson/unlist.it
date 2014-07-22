#Uploading with Dropzone
$(document).ready ->
  Dropzone.autoDiscover = false     # Disable auto-discover

  $("#unimage-dropzone").dropzone(  # Gets our upload form via its id
    maxFilesize: 3,                 # Max filesize is 3mb
    paramName: 'unimage[filename]', # Change the params name of the upload file
    addRemoveLinks: true,           # Show the 'remove' link on each image uploaded
    acceptedFiles: "image/*",       # Only accepts images. DEFINE EXPLICITLY LATER
    dictDefaultMessage: "Drop Images here to upload")

# Deleting with Dropzone
# Listening for Dropzone upload success - loads unimage :id/:token to thumb for use w/deletion
Dropzone.options.unimageDropzone = init: ->
  @on "success", (file, response, event) ->

    # Append the unimage id as a hidden input
    elem = document.createElement('input')
    elem.setAttribute("name", "unimage[id]")
    elem.setAttribute("value", response["id"])
    elem.setAttribute("type", "hidden")
    file.previewTemplate.appendChild elem

    # Append the unimage token as a hidden input
    elem2 = document.createElement('input')
    elem2.setAttribute("name", "unimage[token]")
    elem2.setAttribute("value", response["token"])
    elem2.setAttribute("type", "hidden")
    file.previewTemplate.appendChild elem2

    file.previewTemplate.addEventListener "mouseup", (e) ->
      _this = this
      e.preventDefault()
      e.stopPropagation()
      unimageId = $(_this).parent().find('[name="unimage[id]"]').val()
      unimageToken = $(_this).parent().find('[name="unimage[token]"]').val()
      $.ajax
        url: "/remove_unimage"
        type: "DELETE"
        dataType: "script"
        data:
          unimage:
            id: unimageId
            token: unimageToken
      false
    false

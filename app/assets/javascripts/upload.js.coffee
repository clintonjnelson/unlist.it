#Uploading with Dropzone
$(document).ready ->
  Dropzone.autoDiscover = false     # Disable auto-discover

  $("#unimage-dropzone").dropzone(  # Gets our upload form via its id
    maxFilesize: 3,                 # Max filesize is 3mb
    paramName: 'unimage[filename]', # Change the params name of the upload file
    addRemoveLinks: true,           # Show the 'remove' link on each image uploaded
    acceptedFiles: "image/*",       # Only accepts images. DEFINE EXPLICITLY LATER
    dictDefaultMessage: "Drop Images here to upload")


# Listening for Dropzone upload success - loads unimage ID to thumb for use w/deletion
Dropzone.options.unimageDropzone = init: ->
  @on "success", (file, response, event) ->

    # Append the unimage id as a hidden input
    elem = document.createElement('input')
    elem.setAttribute("name", "id")
    elem.setAttribute("value", response["id"])
    elem.setAttribute("type", "hidden")
    file.previewTemplate.appendChild elem

    # Append the unimage token as a hidden input
    elem2 = document.createElement('input')
    elem2.setAttribute("name", "token")
    elem2.setAttribute("value", response["token"])
    elem2.setAttribute("type", "hidden")
    file.previewTemplate.appendChild elem2

    $('.dz-remove').on "click", ((e) ->
      _this = this
      e.preventDefault()
      e.stopPropagation()
      imageId = $(_this).parent().find('[name="id"]').val()
      imageToken = $(_this).parent().find('[name="token"]').val()
      console.log _this
      console.log imageId
      console.log imageToken
      $.ajax
        url: "/remove_unimage"
        type: "DELETE"
        dataType: "script"
        data:
          id: imageId
          token: imageToken
      false), false



  # $('.dz-remove').addEventListener "click", (->
  #     $.ajax
  #       type: "post"
  #       url: "/remove_unimage"
  #       dataType: "script"
  #       data:
  #         file.previewTemplate.find('input').val()
  #     false), false

  # $(".dz-remove").on "click", (e) ->
  #   e.preventDefault()
  #   e.stopPropagation()
  #   _this = this
  #   imageId = $(_this).parent().find('[name="id"]').val()
  #   imageToken = $(_this).parent().find('[name="token"]').val()
  #   $.ajax
  #     url: "/remove_unimage"
  #     type: "DELETE"
  #     dataType: "script"
  #     data:
  #       id: imageId
  #       token: imageToken



    # file.previewTemplate.find('.dz-remove').addEventListener "click", (->
    #   $.ajax
    #     type: "post"
    #     url: "/remove_unimage"
    #     dataType: "script"
    #     data:
    #       file.previewTemplate.find('input').val()
    #   false), false

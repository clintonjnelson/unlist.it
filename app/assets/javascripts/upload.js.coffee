$ ->
  $("#upload-image").fileupload
  add: (e, data) ->
    data.context = $("#submit-data")
    data.submit()

# jQuery ->
#   # Changes file name from an array to a single upload.
#   $('#upload_uploaded_file').attr('name','upload[uploaded_file]')
#   $('#new_upload').fileupload
#     dataType: 'script'

#     #Validation of file type
#     add: (e, data) ->
#       types = /(\.|\/)(gif|jpe?g|png|tif)$/i
#       file = data.files[0]
#       # OK files are appended to the list of pictures for uploading
#       if types.test(file.type) || types.test(file.name)
#         data.context = $(tmpl("template-upload", file))
#         $('#new_upload').append(data.context)
#         data.submit()
#       else
#         # Wrong file type results in Alert to the user
#         alert("#{file.name} is not a gif, jpg, png, or tif image file")

#     #Show progress bar
#     progress: (e, data) ->
#       if data.context
#         progress = parseInt(data.loaded / data.total * 100, 10)
#         data.context.find('.bar').css('width', progress + '%')

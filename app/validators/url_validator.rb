# I'm pretty proud of this one...
# It both checks the URI (standard practice) & verifies response

class UrlValidator < ActiveModel::EachValidator
  require "net/http"

  def validate_each(record, attribute, value)
    valid = begin
      (URI.parse(value).kind_of?(URI::HTTP) && verify_exists?(value))
    rescue URI::InvalidURIError
      false
    end
    unless valid
      record.errors.add(attribute, error_message)
    end
  end

  def verify_exists?(url_string)
    url = URI.parse(url_string)
    binding.pry
    request = Net::HTTP.new(url.host, url.port)
    request.use_ssl = (url.scheme == 'https')
    path = url.path if url.path.present?
    res = request.request_head(path || '/')
    if res.kind_of?(Net::HTTPRedirection)
      url_exist?(res['location']) # Go after any redirect and make sure you can access the redirected URL
    else
      ! %W(4 5).include?(res.code[0]) # Not from 4xx or 5xx families
    end
  rescue Errno::ENOENT, SocketError
    false #false if can't find the server
  request.finish if request.active?
  end

  def error_message
    message = (options[:message] || "is not a valid address. Please try again.")
  end
end


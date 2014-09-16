# I'm pretty proud of this one...
# It both checks the URI (standard practice) & verifies response

class UrlValidator < ActiveModel::EachValidator
  require "net/http"
  require "net/https"

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
    begin
      url      = URI.parse(url_string)
      http     = Net::HTTP.new(url.host, url.port)
      case url.scheme
        when "http"
          request  = Net::HTTP::Get.new(url.request_uri)
        when "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          request = Net::HTTP::Get.new(url.request_uri)
      end
      response = http.request(request)
      if response.kind_of?(Net::HTTPRedirection)
        verify_exists?(response['location']) # Recursive check redirect and make sure you can access the redirected URL
      else
        ! %W(4).include?(response.code[0]) # Not 4xx status types; 5xx at least indicates hit something
      end
    rescue Errno::ENOENT, SocketError
      false #false if can't find the server
    rescue NoMethodError #Catch-All for unhandled edge-cases; allow if unclear
      true
    end
    #request.finish# if request.active? not required for GET
  end

  def error_message
    message = (options[:message] || "is not a valid address. Please try again.")
  end
end


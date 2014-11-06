class AmazonecsManager
  attr_reader :error #:url, :asin, :unlist_link, :associate, #parsed_asin, created_url
  def initialize(options={})
    @associate = "unlist-20"
    @url       = options[:url]  if valid_url?( options[:url ])
    @asin      = options[:asin] if valid_asin?(options[:asin])
    return "invalid initialize - url or asin required" unless @url || @asin

    @request   = Vacuum.new
    @request.configure( aws_access_key_id:     'AKIAJWAFSGIVTNTV5UDQ',
                        aws_secret_access_key: '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',
                        associate_tag:          @associate )
  end



  ############################## INSTANCE METHODS ##############################
  def get_product_image
    if @asin.present? || @url.present?
      @asin.blank? ? (asin = asin_from_url) : (asin = @asin)
      return request_and_retrieve_images(asin)
    else
      nil
    end
  end

  def asin_from_url(url=@url)
    url.present? ? asin_parse(url) : nil
  end

  def amazon_link(asin=@asin, associate=nil)
    if asin.present?
      return @unlist_link = (associate.nil? ? "http://www.amazon.com/dp/#{asin}" : "http://www.amazon.com/dp/#{asin}/?tag=#{@associate}")
    elsif @url.present?
      asin = asin_from_url(@url)
      amazon_link(asin, associate)     #recursive call
    else
      nil
    end
  end




  ############################## PRIVATE METHODS ###############################
  private
  def request_and_retrieve_images(asin)
    response = @request.item_lookup(query: { "ItemId" => asin, "IdType" => "ASIN", "Condition" => "All", "ResponseGroup" => "Images" })#CODE HERE TO GET THE IMAGE RESPONSE
    response.to_h["ItemLookupResponse"]["Items"]["Item"]["LargeImage"]["URL"]
  end

  def asin_parse(url)
    if url.present?
      arrayed_value = url.scan(/(?:\/)([A-Z0-9]{10}){1}(?:\/|$)/)
      arrayed_value[0][0].present? ? arrayed_value[0][0] : (@error = "invalid url")
    else
      @error = "no url"
    end
  end

  def valid_url?(url)
    if url.blank? || url.scan(/(?:\/)([A-Z0-9]{10}){1}(?:\/|$)/).blank?
      false
    else
      true
    end
  end

  def valid_asin?(asin)
    if asin.blank? || asin.length != 10 || asin.scan(/([A-Z0-9]{10}){1}/).blank?
      false
    else
      true
    end
  end
end

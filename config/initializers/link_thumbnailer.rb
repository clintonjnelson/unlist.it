# Use this hook to configure LinkThumbnailer bahaviors.
LinkThumbnailer.configure do |config|
  # Numbers of redirects before raising an exception when trying to parse given url.
  config.redirect_limit = 3

  # Set user agent
  config.user_agent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.13) Gecko/20080311 Firefox/2.0.0.13"
                       # "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5",
                       # "Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.7a) Gecko/20050614 Firefox/0.9.0+",
                       # "Opera/9.25 (Windows NT 6.0; U; en)",
                       # "Mozilla/4.0 (compatible; MSIE 5.15; Mac_PowerPC)",
                       # "Opera/9.52 (X11; Linux i686; U; en)" ].sample #picks from array, if helpful

  # Enable or disable SSL verification
  # config.verify_ssl = true

  # The amount of time in seconds to wait for a connection to be opened.
  # If the HTTP object cannot open a connection in this many seconds,
  # it raises a Net::OpenTimeout exception.
  # See http://www.ruby-doc.org/stdlib-2.1.1/libdoc/net/http/rdoc/Net/HTTP.html#open_timeout
  config.http_timeout = 5

  # List of blacklisted urls you want to skip when searching for images.
  config.blacklist_urls = [
    %r{^http://ad\.doubleclick\.net/},
    %r{^http://b\.scorecardresearch\.com/},
    %r{^http://pixel\.quantserve\.com/},
    %r{^http://s7\.addthis\.com/}
  ]

  # List of attributes you want LinkThumbnailer to fetch on a website.
  config.attributes = [:title, :images] #Removed :description, :video

  # List of procedures used to rate the website description. Add your custom class
  # here. Note that the order matters to compute the score. See wiki for more details
  # on how to build your own graders.
  #
  # config.graders = [
  #   ->(description) { ::LinkThumbnailer::Graders::Length.new(description) },
  #   ->(description) { ::LinkThumbnailer::Graders::HtmlAttribute.new(description, :class) },
  #   ->(description) { ::LinkThumbnailer::Graders::HtmlAttribute.new(description, :id) },
  #   ->(description) { ::LinkThumbnailer::Graders::Position.new(description) },
  #   ->(description) { ::LinkThumbnailer::Graders::LinkDensity.new(description) }
  # ]

  # Minimum description length for a website.
  #
  # config.description_min_length = 25

  # Regex of words considered positive to rate website description.
  #
  # config.positive_regex = /article|body|content|entry|hentry|main|page|pagination|post|text|blog|story/i

  # Regex of words considered negative to rate website description.
  #
  # config.negative_regex = /combx|comment|com-|contact|foot|footer|footnote|masthead|media|meta|outbrain|promo|related|scroll|shoutbox|sidebar|sponsor|shopping|tags|tool|widget|modal/i

  # Numbers of images to fetch. Fetching too many images will be slow.
  config.image_limit = 7

  # Whether you want LinkThumbnailer to return image size and type or not.
  # Setting this value to false will increase performance since for each images, LinkThumbnailer
  # does not have to fetch its size and type.
  config.image_stats = true
end

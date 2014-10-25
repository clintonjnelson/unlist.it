# Set the host name for URL creation
#if Rails.env.production?
  SitemapGenerator::Sitemap.default_host = "http://www.unlist.it"
  SitemapGenerator::Sitemap.sitemaps_host = "http://s3.amazonaws.com/"
  SitemapGenerator::Sitemap.sitemaps_path = "#{ENV['PUBLIC_AWS_BUCKET']}"
  SitemapGenerator::Sitemap.public_path = 'tmp/'
  SitemapGenerator::Sitemap.create_index = true
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new
  SitemapGenerator::Sitemap.adapter.fog_directory = "#{ENV['PUBLIC_AWS_BUCKET']}"

  # SitemapGenerator::Sitemap.create do
  #   # Put links creation logic here.
  #   #
  #   # The root path '/' and sitemap index file are added automatically for you.
  #   # Links are added to the Sitemap in the order they are specified.
  #   #
  #   # Usage: add(path, options={})
  #   #        (default options are used if you don't specify)
  #   #
  #   # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #   #           :lastmod => Time.now, :host => default_host
  #   #
  #   # Examples:
  #   #
  #   # Add '/articles'
  #   #
  #   #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #   #
  #   # Add all articles:
  #   # Article.find_each do |article|
  #   #   add article_path(article), :lastmod => article.updated_at
  #   # end
  # end
#end



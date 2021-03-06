# Set the host name for URL creation
if Rails.env.production?
  SitemapGenerator::Sitemap.default_host  = "http://www.unlist.it"
  SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['PUBLIC_AWS_BUCKET']}.s3.amazonaws.com/"
  SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/"
  SitemapGenerator::Sitemap.public_path   = "tmp/"
  SitemapGenerator::Sitemap.ping_search_engines('http://www.unlist.it/sitemap.xml.gz')
  SitemapGenerator::Sitemap.adapter       = SitemapGenerator::S3Adapter.new(    aws_access_key_id: "#{ENV['AWS_ACCESS_KEY']}",
                                                                            aws_secret_access_key: "#{ENV['AWS_SECRET_KEY']}")

  #SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new
  #SitemapGenerator::Sitemap.adapter.fog_directory = "#{ENV['PUBLIC_AWS_BUCKET']}"

  SitemapGenerator::Sitemap.create do
    add '/home'
    add '/browse'
    add '/tour'
    add '/faq'
    add '/about'
    add '/contact'
    add '/gettingstarted'
    add '/signup'
    add '/forgot_password'
    add '/blogposts'

    # Links for browsing the various categories on Unlist.it
    Category.find_each do |category|
      add browse_category_path(category_id: category.slug)
    end

    # Links for each unlisting
    Unlisting.active.find_each do |unlisting|
      add unlisting_path(unlisting.slug)
    end

    # Links for each active user
    User.find_each do |user| ###NEED A VERSION OF THIS THAT ONLY LOADS ACTIVE USERS
      add user_path(user.slug)
    end
  end
end


# Put links creation logic here.
    #
    # The root path '/' and sitemap index file are added automatically for you.
    # Links are added to the Sitemap in the order they are specified.
    #
    # Usage: add(path, options={})
    #        (default options are used if you don't specify)
    #
    # Defaults: :priority => 0.5, :changefreq => 'weekly',
    #           :lastmod => Time.now, :host => default_host
    #
    # Examples:
    #
    # Add '/articles'
    #
    #   add articles_path, :priority => 0.7, :changefreq => 'daily'
    #
    # Add all articles:
    # Article.find_each do |article|
    #   add article_path(article), :lastmod => article.updated_at
    # end


# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://bikeindex.org"
SitemapGenerator::Sitemap.sitemaps_host = "https://bikeindex.s3.amazonaws.com"
SitemapGenerator::Sitemap.public_path = "#{Rails.root}/tmp/uploads"
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.adapter = SitemapGenerator::WaveAdapter.new

SitemapGenerator::Sitemap.create do
  group(:filename => :about) do
    paths = ["about"]
    paths.each { |i| add "/#{i}", priority: 0.9 }
  end

  group(:filename => :news) do
    add '/blogs', priority: 0.9, :changefreq => 'daily'
    Blog.published.each do |b|
      add("/blogs/#{b.title_slug}", priority: 0.9, :news => {
          :publication_name => "Bike Index Blog",
          :publication_language => "en",
          :title => b.title,
          :publication_date => b.published_at.utc
      })
    end
  end

  group(:filename => :partners) do
    paths = ["where", "vendor_signup",]
    paths.each { |i| add "/#{i}", priority: 0.9 }
  end

  group(:filename => :documentation) do
    add '/documentation/api_v1'
  end

  group(:filename => :bikes) do
    Bike.scoped.each { |b| add bike_path(b), priority: 0.9 }
  end

  group(:filename => :images) do
    PublicImage.bikes.each do |i|
      add(bike_path(i.imageable), :images => [{
        :loc => i.image_url,
        :title => i.name }])
    end
  end

  group(:filename => :users) do
    User.where(show_bikes: true).each { |u| add "/users/#{u.username}", priority: 0.4 }
  end

  group(:filename => :contact) do
    paths = ["contact_us"]
    paths.each { |i| add "/#{i}", priority: 0.8 }
  end


  group(:filename => :bike_manufacturers) do
    add "/manufacturers", priority: 0.5
    Manufacturer.scoped.each { |m| add "/manufacturers/#{m.slug}", priority: 0.4 }
  end

  group(:filename => :resources) do
    paths = ["resources", "stolen_bikes", "serials", "stolen", "spokecard"]
    paths.each { |i| add "/#{i}" }                
  end

end
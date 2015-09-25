# Crawly
# Simple single domain crawler and sitemap builder
#
# Uses redis to store urls during visits:
# - visited: avoid url re-visit
# - sitemapped: flag urls ready to be rendered as xml
# this provide foundations for resumable visites.
#
# Used redis sets are cleaned after visiting a website.
#
# Uses recursion.
# Uses a giang Regex pattern to validate urls
# Stores locations for images: png|jp(e)g|svg|gif allowed
#
# Skips 404s.
class Crawly
  attr_reader :base_url, :max_size

  def initialize(base_url, max_size = 50)
    @base_url = base_url
    @redis = Redis.new
    @extractor = Extractor.new(domain)
    @sitemap = Sitemap.new
    @max_size = max_size.to_i
  end

  def domain
    u = URI.encode(base_url)
    "#{URI.parse(u).scheme}://#{URI.parse(u).host}"
  end

  def sitemap
    sitemap_urls.each do |url|
      if imgs_for(url).size > 0
        @sitemap.add(url, images: imgs_for(url))
      else
        @sitemap.add(url)
      end
    end
    @sitemap.write
  end

  def swim(url = base_url)
    check_url(url)
    begin
      open(url) do |f|
        urls, images = @extractor.extract(f.read)
        urls -= visited_urls

        store_page_images(url, images)
        sitemap!(url) unless sitemapped?(url)
        mark_as_visited!(url)

        urls.each do |u|
          break if max_reached?
          next if visited?(u)
          swim(u)
        end
      end
    rescue OpenURI::HTTPError => e
      puts "Unable to open #{url} because #{e}, skipping..."
    end
  end

  def clean
    urls = @redis.smembers("crawly:#{h_domain}:visited")
    @redis.del("crawly:#{h_domain}:visited")
    @redis.del("crawly:#{h_domain}:sitemapped")
    urls.each do |url|
      @redis.del("crawly:#{h_domain}:img_for:#{url_to_hash(url)}")
    end
  end

  private

  def visited?(url)
    @redis.sismember("crawly:#{h_domain}:visited", url)
  end

  def visited_urls
    @redis.smembers("crawly:#{h_domain}:visited")
  end

  def sitemapped?(url)
    @redis.sismember("crawly:#{h_domain}:sitemapped", url)
  end

  def sitemap!(url)
    @redis.sadd("crawly:#{h_domain}:sitemapped", url)
  end

  def mark_as_visited!(url)
    @redis.sadd("crawly:#{h_domain}:visited", url)
  end

  def sitemap_urls
    @redis.smembers("crawly:#{h_domain}:sitemapped")
  end

  def imgs_for(url)
    @redis.smembers("crawly:#{h_domain}:img_for:#{url_to_hash(url)}")
  end

  def store_page_images(url, images)
    Array(images).each do |src|
      @redis.sadd("crawly:#{h_domain}:img_for:#{url_to_hash(url)}", src)
    end
  end

  def check_url(url)
    unless Crawly::Extractor.url_is_valid?(url)
      puts "Cannot swim website: '#{url}' is wrong."
      exit
    end
  end

  def max_reached?
    # +1 to account root/current_page
    @redis.scard("crawly:#{h_domain}:visited") + 1 == @max_size
  end

  def url_to_hash(url)
    Digest::SHA1.hexdigest(URI.parse(url.to_s).path)[0..7]
  end

  def h_domain
    Digest::SHA1.hexdigest(domain)[0..7]
  end
end

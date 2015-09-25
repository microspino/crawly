class Crawly
  # Extractor:
  # Extract images and new urls to visit from every page
  class Extractor
    attr_reader :domain

    def initialize(domain)
      @domain = domain
    end

    def self.url_is_valid?(url)
      url.to_s =~ PERFECT_URL_PATTERN
    end

    def extract(txt = '')
      urls = extract_hrefs(txt)
      image_hrefs = urls.select do |u|
        u.match(/\.(jpe?g|gif|png|svg)/i)
      end
      images = image_hrefs + extract_image_sources(txt)
      urls -= image_hrefs
      [urls, images]
    end

    private

    def extract_image_sources(txt)
      Oga.parse_html(txt).xpath('//@src').map do |src|
        next if ico_js_or_css?(src)
        rel_to_abs(src.value)
      end.compact.uniq
    end

    def extract_hrefs(txt)
      Oga.parse_html(txt).xpath('//@href').map do |href|
        href = href.value.to_s
        next if href.empty? || href == '/'
        process(href)
      end.compact.uniq
    end

    def process(href)
      url = rel_to_abs(href)
      return if url.to_s.empty? || ico_js_or_css?(url) || anchor?(url)
      url.to_s if self.class.url_is_valid?(url) && same_domain?(url)
    end

    def rel_to_abs(href)
      begin
        url = URI.parse href.to_s.chomp('/')
      rescue ArgumentError => ae
        puts "Skipping #{url} :( because #{ae}"
      rescue URI::InvalidURIError => ie
        puts "Can't handle #{url} :( because #{ie} skipping..."
        nil
      end
      URI.join(domain, url) if url.relative?
    end

    def same_domain?(url)
      a = url.host.split('.').last(2).join('.')
      b = URI.parse(domain).host.split('.').last(2).join('.')
      a == b
    end

    def anchor?(url)
      url.to_s[0, 1] == '#'
    end

    def ico_js_or_css?(url)
      url.to_s.match(/\.(js|css|ico)/)
    end
  end
end

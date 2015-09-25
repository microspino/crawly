class Crawly
  class Sitemap
    SCHEMAS = { 'image' => 'http://www.google.com/schemas/sitemap-image/1.1' }
    
    def initialize
      @xml_start = <<-SITEMAPXML
        <?xml version="1.0" encoding="UTF-8"?>
          <urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
              http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
            xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
            xmlns:image="#{SCHEMAS['image']}"
            xmlns:xhtml="http://www.w3.org/1999/xhtml">
      SITEMAPXML
      @xml_start.gsub!(/\s+/, ' ').gsub!(/ *> */, '>').strip!
      @xml_content = ''
      @xml_end = %q(</urlset>)
    end

    def write
      @xml_start + @xml_content + @xml_end
    end

    def add(link, opts = {})
      s_url = Crawly::SitemapUrl.new(link, opts)
      @xml_content << s_url.to_xml
    end
  end
end

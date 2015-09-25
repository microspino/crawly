class Crawly::SitemapUrl < Hash
  def initialize(path, opts={})
    self.merge!(
    :priority   => opts[:priority],
    :changefreq => opts[:changefreq],
    :lastmod    => opts[:lastmod],
    :expires    => opts[:expires],
    :host       => opts[:host],
    :loc        => path,
    :images     => opts[:images] || [],
    )
  end
    
  def to_xml
    builder = ::Builder::XmlMarkup.new
    builder.url do
      builder.loc self[:loc]

      self[:images].each do |image|
        builder.image:image do
          builder.image :loc, image
        end
      end

    end
    builder << ''
  end
end
require 'minitest/autorun'
require 'minitest/pride'
require 'crawly'

class ExtractorTest < Minitest::Test
  def setup
    @base_url = 'http://microspino.com'
    @xtr = Crawly::Extractor.new(@base_url)
  end

  def test_same_domain?
    a = URI.parse('http://microspino.com/contact_me')
    b = URI.parse('http://leanpanda.com')
    assert @xtr.send(:same_domain?, a)
    refute @xtr.send(:same_domain?, b)
  end

  def test_is_anchor?
    assert @xtr.send(:is_anchor?, '#top')
  end

  def test_ico_js_or_css?
    js_url = 'http://microspino.com/js/plugins.js'
    js_min_url = 'http://microspino.com/js/vendor/modernizr-2.6.2.min.js'
    assert @xtr.send(:ico_js_or_css?, js_url)
    assert @xtr.send(:ico_js_or_css?, js_min_url)

    png_url = 'http://microspino.com/apple-touch-icon-76x76.png'
    svg_url = '/img/iphone-shape.svg'
    refute @xtr.send(:ico_js_or_css?, png_url)
    refute @xtr.send(:ico_js_or_css?, svg_url)
  end

  def test_url_is_valid?
    assert @xtr.class.url_is_valid?('http://microspino.com/contact_me')
    refute @xtr.class.url_is_valid?('/contact_me') # <- needs to be abs url
    refute @xtr.class.url_is_valid?('tel:+3390029932002')
  end
end

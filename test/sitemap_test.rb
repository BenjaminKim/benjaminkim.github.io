require "minitest/autorun"
require "rexml/document"

class SitemapTest < Minitest::Test
  SITEMAP_PATH = File.expand_path("../_site/sitemap.xml", __dir__)
  SITEMAP_NAMESPACE = "http://www.sitemaps.org/schemas/sitemap/0.9"

  def test_uses_standard_sitemap_namespace
    assert_equal SITEMAP_NAMESPACE, sitemap.root.namespace
  end

  def test_homepage_uses_latest_post_last_modified_date
    homepage, _about, latest_post = sitemap_entries

    assert_equal "https://jeho.page/", location(homepage)
    assert_equal last_modified(latest_post), last_modified(homepage)
  end

  def test_about_page_uses_canonical_trailing_slash_url
    about = sitemap_entries.find { |entry| location(entry).start_with?("https://jeho.page/about") }

    assert_equal "https://jeho.page/about/", location(about)
  end

  private

  def sitemap
    @sitemap ||= begin
      flunk "_site/sitemap.xml 파일이 없습니다. 먼저 `bundle exec jekyll build`를 실행하세요." unless File.file?(SITEMAP_PATH)

      REXML::Document.new(File.read(SITEMAP_PATH))
    end
  end

  def sitemap_entries
    sitemap.root.elements.to_a("url")
  end

  def location(entry)
    entry.elements["loc"].text
  end

  def last_modified(entry)
    entry.elements["lastmod"].text
  end
end

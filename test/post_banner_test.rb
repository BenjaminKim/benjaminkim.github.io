require "minitest/autorun"
require "json"
require "nokogiri"
require "uri"

class PostBannerTest < Minitest::Test
  SITE_DIR = File.expand_path("../_site", __dir__)
  POST_PATH = "essay/2026/08/02/programmer-lifespan.html"

  def setup
    flunk "_site 디렉터리가 없습니다. 먼저 `bundle exec jekyll build`를 실행하세요." unless File.directory?(SITE_DIR)

    @post_html = read_page(POST_PATH)
  end

  def test_post_has_one_banner_between_share_controls_and_comments
    banner_marker = 'class="post-banner"'

    assert_equal 1, @post_html.scan(banner_marker).size
    assert_operator index_of('id="awesome-rss-button"'), :<, index_of(banner_marker)
    assert_operator index_of(banner_marker), :<, index_of("https://giscus.app/client.js")
  end

  def test_banner_has_trackable_link_and_responsive_image_metadata
    assert_includes @post_html, 'href="https://withcoffee.app?utm_source=jeho_page_post_banner&amp;utm_medium=blog"'
    assert_includes @post_html, 'src="/assets/img/apps/coffee-post-banner.webp"'
    assert_includes @post_html, 'alt="커피한잔, 직장인의 블라인드소개팅"'
    assert_includes @post_html, 'width="1400"'
    assert_includes @post_html, 'height="350"'
    assert_includes @post_html, 'loading="lazy"'
    assert_includes @post_html, 'decoding="async"'
  end

  def test_both_banner_options_have_matching_links_and_built_images
    document = Nokogiri::HTML(@post_html)
    options = document.css('[data-post-banner] [data-banner-options]')
    assert_equal 1, options.size

    banners = JSON.parse(options.first.text)
    assert_equal ["coffee", "campus-couple"], banners.map { |banner| banner.fetch("id") }
    assert_equal ["withcoffee.app", "campus-couple.com"], banners.map { |banner| URI(banner.fetch("url")).host }

    banners.each do |banner|
      assert_includes banner.fetch("url"), "utm_source=jeho_page_post_banner"
      assert_includes banner.fetch("url"), "utm_medium=blog"
      assert_includes banner.fetch("alt"), banner.fetch("name")
      assert File.file?(File.join(SITE_DIR, banner.fetch("image"))), "배너 이미지가 없습니다: #{banner.fetch('image')}"
    end

    assert_equal 1, document.css('script[src="/assets/js/post-banner.js"]').size
    assert File.file?(File.join(SITE_DIR, "assets/js/post-banner.js"))
  end

  def test_banner_is_not_rendered_on_home_or_about_pages
    ["index.html", "about/index.html"].each do |path|
      html = read_page(path)
      refute_includes html, 'class="post-banner"'
      refute_includes html, '/assets/js/post-banner.js'
    end
  end

  private

  def read_page(relative_path)
    path = File.join(SITE_DIR, relative_path)
    flunk "#{relative_path} 빌드 결과가 없습니다." unless File.file?(path)

    File.read(path)
  end

  def index_of(fragment)
    @post_html.index(fragment) || flunk("#{fragment.inspect}를 게시물에서 찾을 수 없습니다.")
  end
end

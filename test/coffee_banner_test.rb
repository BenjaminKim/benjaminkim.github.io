require "minitest/autorun"

class CoffeeBannerTest < Minitest::Test
  SITE_DIR = File.expand_path("../_site", __dir__)
  POST_PATH = "essay/2026/08/02/programmer-lifespan.html"

  def setup
    flunk "_site 디렉터리가 없습니다. 먼저 `bundle exec jekyll build`를 실행하세요." unless File.directory?(SITE_DIR)

    @post_html = read_page(POST_PATH)
  end

  def test_post_has_one_banner_between_share_controls_and_comments
    banner_marker = 'class="post-coffee-banner"'

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

  def test_banner_is_not_rendered_on_home_or_about_pages
    refute_includes read_page("index.html"), 'class="post-coffee-banner"'
    refute_includes read_page("about/index.html"), 'class="post-coffee-banner"'
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

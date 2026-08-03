require "minitest/autorun"

class HomeSeoTest < Minitest::Test
  HOME_PATH = File.expand_path("../_site/index.html", __dir__)
  DESCRIPTION = "1인 개발자 김재호가 소프트웨어 개발, 커리어, 제품 운영과 일상을 기록하는 개인 블로그입니다."
  IMAGE_URL = "https://jeho.page/assets/img/home-og.jpg"
  IMAGE_ALT = "K리그 프로그래머의 스몰토크 텍스트 썸네일"

  def setup
    flunk "_site/index.html 파일이 없습니다. 먼저 `bundle exec jekyll build`를 실행하세요." unless File.file?(HOME_PATH)

    @html = File.read(HOME_PATH)
  end

  def test_homepage_has_descriptive_search_metadata
    assert_includes @html, %(<meta name="description" content="#{DESCRIPTION}" />)
    assert_includes @html, %(<meta property="og:description" content="#{DESCRIPTION}" />)
    assert_includes @html, %(<meta name="twitter:description" content="#{DESCRIPTION}" />)
    assert_includes @html, %(<link rel="canonical" href="https://jeho.page/" />)
  end

  def test_homepage_has_complete_image_metadata
    assert_includes @html, %(<meta property="og:image" content="#{IMAGE_URL}" />)
    assert_includes @html, %(<meta property="og:image:width" content="1200" />)
    assert_includes @html, %(<meta property="og:image:height" content="630" />)
    assert_includes @html, %(<meta property="og:image:type" content="image/jpeg" />)
    assert_includes @html, %(<meta property="og:image:alt" content="#{IMAGE_ALT}" />)
    assert_includes @html, %(<meta name="twitter:image:alt" content="#{IMAGE_ALT}" />)
  end

  def test_homepage_keeps_the_visible_content_to_the_post_list
    refute_includes @html, 'class="home-intro"'
    refute_includes @html, '<img'
    assert_includes @html, '<h2 class="post-list-heading">최근 글</h2>'
  end
end

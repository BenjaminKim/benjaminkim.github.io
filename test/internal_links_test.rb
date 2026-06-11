require "minitest/autorun"
require "html-proofer"

# 빌드된 _site 의 내부 링크가 모두 실제 파일로 연결되는지 검사한다.
# 외부 링크는 test/external_links_test.rb 에서 별도로 검사한다.
class InternalLinksTest < Minitest::Test
  SITE_DIR = File.expand_path("../_site", __dir__)

  def test_internal_links
    flunk "_site 디렉터리가 없습니다. 먼저 `bundle exec jekyll build` 를 실행하세요." unless File.directory?(SITE_DIR)

    HTMLProofer.check_directory(
      SITE_DIR,
      disable_external: true,
      enforce_https: false,  # 오래된 글의 http 링크 허용
      allow_hash_href: true,
      checks: ["Links"],
      # 자기 사이트로 향하는 절대 링크는 내부 링크로 취급해서 검사
      swap_urls: { %r{\Ahttps://jeho\.page} => "" }
    ).run
  rescue StandardError => e
    flunk e.message
  end
end

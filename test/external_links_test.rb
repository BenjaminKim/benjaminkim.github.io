require "minitest/autorun"
require "html-proofer"

# 빌드된 _site 의 외부 링크가 살아있는지 실제 HTTP 요청으로 검사한다.
# 결과는 tmp/.htmlproofer 에 30일간 캐시되므로 두 번째 실행부터는 빠르다.
# 실행: bundle exec rake test:external
class ExternalLinksTest < Minitest::Test
  SITE_DIR = File.expand_path("../_site", __dir__)

  # 봇 요청을 차단해 정상 링크인데도 에러를 반환하는 사이트들
  IGNORE_URLS = [
    %r{linkedin\.com},  # HTTP 999
    %r{threads\.net},
    %r{twitter\.com},
    %r{x\.com},
    %r{medium\.com},    # HTTP 403
    # head 의 preconnect 대상 도메인 (루트가 404 를 반환하는 게 정상)
    "https://fonts.googleapis.com",
    "https://fonts.gstatic.com",
  ].freeze

  # 죽은 것이 확인되어 검사에서 제외하는 링크들 (2026-06-11 확인)
  KNOWN_DEAD_URLS = [
  ].freeze

  def test_external_links
    flunk "_site 디렉터리가 없습니다. 먼저 `bundle exec jekyll build` 를 실행하세요." unless File.directory?(SITE_DIR)

    HTMLProofer.check_directory(
      SITE_DIR,
      checks: ["Links"],
      enforce_https: false,       # 오래된 글의 http 링크 허용
      check_external_hash: false, # 페이지 생존만 검사, 앵커(#) 존재 여부는 검사 안 함
      allow_hash_href: true,
      ignore_urls: IGNORE_URLS + KNOWN_DEAD_URLS,
      ignore_status_codes: [429],  # rate limit 은 죽은 링크가 아님

      swap_urls: { %r{\Ahttps://jeho\.page} => "" },
      cache: { timeframe: { external: "30d" } },
      hydra: { max_concurrency: 20 },
      typhoeus: {
        connecttimeout: 10,
        timeout: 30,
        followlocation: true,
        headers: { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) html-proofer" }
      }
    ).run
  rescue StandardError => e
    flunk e.message
  end
end

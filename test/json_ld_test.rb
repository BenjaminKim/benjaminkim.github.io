require "json"
require "minitest/autorun"

class JsonLdTest < Minitest::Test
  SITE_DIR = File.expand_path("../_site", __dir__)

  def test_all_json_ld_blocks_are_valid_json
    each_html_file do |path|
      json_ld_blocks(path).each_with_index do |block, index|
        JSON.parse(block)
      rescue JSON::ParserError => e
        flunk "#{path} JSON-LD block #{index + 1} is invalid: #{e.message}"
      end
    end
  end

  def test_home_page_graph_describes_site_person_and_blog
    graph = graph_for("index.html")

    assert_graph_type graph, "WebSite"
    assert_graph_type graph, "Person"
    assert_graph_type graph, "CollectionPage"
    assert_graph_type graph, "Blog"
  end

  def test_about_page_graph_describes_profile_and_visible_apps
    graph = graph_for("about/index.html")

    assert_graph_type graph, "ProfilePage"
    assert_graph_type graph, "BreadcrumbList"
    assert_operator graph.count { |node| %w[MobileApplication WebApplication].include?(node["@type"]) }, :>=, 8
  end

  def test_post_graph_describes_blog_post_and_breadcrumb
    graph = graph_for("essay/2026/06/09/coffee-holdings.html")

    assert_graph_type graph, "WebPage"
    assert_graph_type graph, "Blog"
    assert_graph_type graph, "BlogPosting"
    assert_graph_type graph, "BreadcrumbList"

    posting = graph.find { |node| node["@type"] == "BlogPosting" }
    assert_equal({ "@id" => "https://jeho.page/#person" }, posting["author"])
    assert_equal({ "@id" => "https://jeho.page/#person" }, posting["publisher"])
  end

  private

  def each_html_file(&block)
    flunk "_site 디렉터리가 없습니다. 먼저 `bundle exec jekyll build` 를 실행하세요." unless File.directory?(SITE_DIR)

    Dir.glob(File.join(SITE_DIR, "**/*.html"), &block)
  end

  def graph_for(relative_path)
    path = File.join(SITE_DIR, relative_path)
    blocks = json_ld_blocks(path).map { |block| JSON.parse(block) }
    graph_block = blocks.find { |block| block.is_a?(Hash) && block["@graph"].is_a?(Array) }

    assert graph_block, "#{relative_path} does not contain @graph JSON-LD"

    graph_block["@graph"]
  end

  def json_ld_blocks(path)
    File.read(path).scan(%r{<script[^>]+type="application/ld\+json"[^>]*>(.*?)</script>}mi).flatten.map(&:strip)
  end

  def assert_graph_type(graph, type)
    assert graph.any? { |node| node["@type"] == type }, "Expected @graph to include #{type}"
  end
end

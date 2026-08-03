require "fileutils"
require "jekyll"
require "minitest/autorun"
require "tmpdir"

class SeoMetaTest < Minitest::Test
  SEO_META_INCLUDE = File.expand_path("../_includes/seo-meta.html", __dir__)

  def setup
    @source_dir = Dir.mktmpdir("seo-meta-source")
    @destination_dir = Dir.mktmpdir("seo-meta-destination")

    FileUtils.mkdir_p(File.join(@source_dir, "_includes"))
    FileUtils.cp(SEO_META_INCLUDE, File.join(@source_dir, "_includes", "seo-meta.html"))
    File.write(File.join(@source_dir, "_config.yml"), <<~YAML)
      title: Fixture Site
      url: https://example.com
      author:
        name: Fixture Author
    YAML

    write_page("nested", <<~YAML)
      title: Nested image
      description: Nested image description
      image:
        path: /assets/nested.jpg
        width: 1200
        height: 630
        type: image/jpeg
        alt: Nested & image
    YAML
    write_page("flat", <<~YAML)
      title: Flat image
      description: Flat image description
      image: /assets/flat.png
      image_width: 800
      image_height: 600
      image_type: image/png
      image_alt: Flat < image
    YAML
    write_page("plain", <<~YAML)
      title: Plain image
      description: Plain image description
      image: /assets/plain.jpg
    YAML
    write_page("missing-description", <<~YAML)
      title: Missing description
      image: /assets/missing-description.jpg
    YAML

    config = Jekyll.configuration(
      "source" => @source_dir,
      "destination" => @destination_dir,
      "quiet" => true,
      "disable_disk_cache" => true
    )
    Jekyll::Site.new(config).process
  end

  def teardown
    FileUtils.remove_entry(@source_dir) if @source_dir
    FileUtils.remove_entry(@destination_dir) if @destination_dir
  end

  def test_description_is_shared_with_twitter
    html = rendered_page("plain")

    assert_includes html, '<meta name="description" content="Plain image description" />'
    assert_includes html, '<meta property="og:description" content="Plain image description" />'
    assert_includes html, '<meta name="twitter:description" content="Plain image description" />'
  end

  def test_description_tags_are_omitted_when_description_is_unavailable
    html = rendered_page("missing-description")

    refute_includes html, '<meta name="description"'
    refute_includes html, '<meta property="og:description"'
    refute_includes html, '<meta name="twitter:description"'
  end

  def test_nested_image_metadata_uses_jekyll_seo_tag_compatible_schema
    html = rendered_page("nested")

    assert_includes html, '<meta property="og:image" content="https://example.com/assets/nested.jpg" />'
    assert_includes html, '<meta property="og:image:width" content="1200" />'
    assert_includes html, '<meta property="og:image:height" content="630" />'
    assert_includes html, '<meta property="og:image:type" content="image/jpeg" />'
    assert_includes html, '<meta property="og:image:alt" content="Nested &amp; image" />'
    assert_includes html, '<meta name="twitter:image:alt" content="Nested &amp; image" />'
  end

  def test_flat_image_metadata_aliases_are_supported
    html = rendered_page("flat")

    assert_includes html, '<meta property="og:image:width" content="800" />'
    assert_includes html, '<meta property="og:image:height" content="600" />'
    assert_includes html, '<meta property="og:image:type" content="image/png" />'
    assert_includes html, '<meta property="og:image:alt" content="Flat &lt; image" />'
    assert_includes html, '<meta name="twitter:image:alt" content="Flat &lt; image" />'
  end

  def test_optional_image_metadata_is_omitted_when_unavailable
    html = rendered_page("plain")

    assert_includes html, '<meta property="og:image" content="https://example.com/assets/plain.jpg" />'
    assert_includes html, '<meta name="twitter:image" content="https://example.com/assets/plain.jpg" />'
    refute_includes html, "og:image:width"
    refute_includes html, "og:image:height"
    refute_includes html, "og:image:type"
    refute_includes html, "og:image:alt"
    refute_includes html, "twitter:image:alt"
  end

  private

  def write_page(name, front_matter)
    content = ["---", front_matter.rstrip, "---", "{% include seo-meta.html %}", ""].join("\n")
    File.write(File.join(@source_dir, "#{name}.md"), content)
  end

  def rendered_page(name)
    File.read(File.join(@destination_dir, "#{name}.html"))
  end
end

require "rake/testtask"

desc "Jekyll 사이트 빌드"
task :build do
  sh({ "RUBYOPT" => "-W0" }, "bundle exec jekyll build")
end

desc "내부 링크 검사 (빠름, 네트워크 불필요)"
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList[
    "test/internal_links_test.rb",
    "test/json_ld_test.rb",
    "test/home_seo_test.rb",
    "test/coffee_banner_test.rb",
    "test/seo_meta_test.rb",
    "test/sitemap_test.rb"
  ]
  t.warning = false
  t.ruby_opts = ["-W0"]
end

namespace :test do
  desc "외부 링크 검사 (HTTP 요청, 30일 캐시)"
  Rake::TestTask.new(:external) do |t|
    t.test_files = FileList["test/external_links_test.rb"]
    t.warning = false
    t.ruby_opts = ["-W0"]
  end
end

task default: [:build, :test]

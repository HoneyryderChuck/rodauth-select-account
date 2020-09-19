# frozen_string_literal: true

require "bundler/gem_tasks"
require "rdoc/task"
require "rake/testtask"
require "rubocop/rake_task"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.warning = false
end

desc "Run rubocop"
RuboCop::RakeTask.new(:rubocop)


task default: :test


namespace :coverage do
  desc "Aggregates coverage reports"
  task :report do
    return unless ENV.key?("CI")
    require 'simplecov'

    SimpleCov.collate Dir["coverage/**/.resultset.json"]
  end
end

# Doc

rdoc_opts = ["--line-numbers", "--title", "Rodauth OAuth: OAuth 2.0 and OpenID for rodauth"]

begin
  gem "hanna-nouveau"
  rdoc_opts.concat(["-f", "hanna"])
rescue Gem::LoadError
  puts "fodeu"
end

rdoc_opts.concat(["--main", "README.md"])
RDOC_FILES = %w[README.md CHANGELOG.md lib/**/*.rb]+ Dir["doc/*.rdoc"]

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += rdoc_opts
  rdoc.rdoc_files.add RDOC_FILES
end
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

    require "simplecov"

    SimpleCov.collate Dir["coverage/**/.resultset.json"]
  end
end

# Doc

rdoc_opts = ["--line-numbers", "--title", "Rodauth Select Account: Multiple Accounts per session in rodauth."]

rdoc_opts.concat(["--main", "README.md"])
RDOC_FILES = %w[README.md CHANGELOG.md lib/**/*.rb] + Dir["doc/*.rdoc"]

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += rdoc_opts
  rdoc.rdoc_files.add RDOC_FILES
end


desc "Check configuration method documentation"
task :check_method_doc do
  docs = {}
  Dir["doc/*.rdoc"].sort.each do |f|
    meths = File.binread(f).split("\n").grep(/\A(\w+[!?]?(\([^\)]+\))?) :: /).map { |line| line.split(/( :: |\()/, 2)[0] }.sort
    docs[File.basename(f).sub(/\.rdoc\z/, "")] = meths unless meths.empty?
  end
  require "rodauth/select-account"
  docs.each do |f, doc_meths|
    require "./lib/rodauth/features/#{f}"
    feature = Rodauth::FEATURES[f.to_sym]
    meths = (feature.auth_methods + feature.auth_value_methods + feature.auth_private_methods).map(&:to_s).sort
    unless (undocumented_meths = meths - doc_meths).empty?
      puts "#{f} undocumented methods: #{undocumented_meths.join(', ')}"
    end
    unless (bad_doc_meths = doc_meths - meths).empty?
      puts "#{f} documented methods that don't exist: #{bad_doc_meths.join(', ')}"
    end
  end
  puts "#{docs.values.flatten.length} total documented configuration methods"
end
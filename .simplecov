if SimpleCov::VERSION >= "1.0.0"
  SimpleCov.command_name "Minitest"
  SimpleCov.skip ".bundle/"
  SimpleCov.skip "vendor/"
  SimpleCov.skip "test/"
  SimpleCov.command_name "#{RUBY_ENGINE}-#{RUBY_VERSION}"
  SimpleCov.coverage_dir "coverage/#{RUBY_ENGINE}-#{RUBY_VERSION}"
else
  SimpleCov.start do
    command_name "Minitest"
    add_filter "/.bundle/"
    add_filter "/vendor/"
    add_filter "/test/"
    command_name "#{RUBY_ENGINE}-#{RUBY_VERSION}"
    coverage_dir "coverage/#{RUBY_ENGINE}-#{RUBY_VERSION}"
  end
end

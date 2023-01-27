# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rake", "~> 12.3"

gem "bcrypt"
gem "rack_csrf"

gem "roda", ">= 2.0.0"
gem "rodauth"
gem "rodauth-i18n", ">= 0.2.0"
gem "sequel"
gem "tilt"

# Tests/Debug
gem "capybara"
gem "minitest", "~> 5.0"
gem "minitest-hooks"
gem "webmock"

gem "pry"

if RUBY_VERSION < "2.5"
  gem "rubocop", "~> 1.12.0"
  gem "rubocop-performance", "~> 1.10.2"
  gem "simplecov", "~> 0.18.0"
else
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-sequel"
  gem "rubocop-thread_safety"
  gem "simplecov"
end

platform :mri, :truffleruby do
  gem "pry-byebug"
  if RUBY_VERSION >= "2.7.0"
    gem "sqlite3"
  elsif RUBY_VERSION >= "2.6.0"
    gem "sqlite3", "< 1.6.0"
  else
    gem "sqlite3", "< 1.5.0"
  end
end

platform :jruby do
  gem "jdbc-sqlite3"
end

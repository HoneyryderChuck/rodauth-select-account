# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rake", "~> 12.3"

gem "bcrypt"
gem "rack_csrf"

gem "roda"
gem "rodauth"
gem "sequel"
gem "tilt"

# Tests/Debug
gem "capybara"
gem "minitest", "~> 5.0"
gem "minitest-hooks"
gem "webmock"

gem "pry"
gem "rubocop"

platform :mri do
  gem "pry-byebug"
  gem "sqlite3"
end

platform :jruby do
  gem "jdbc-sqlite3"
end

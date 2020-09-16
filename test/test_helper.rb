# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)


require "fileutils"
require "logger"
require "securerandom"
require "capybara"
require "capybara/dsl"
require "minitest/autorun"
require "minitest/hooks"

require "sequel"
require "roda"
require "rodauth/select-account"
require "rodauth/version"
require "bcrypt"

ENV["DATABASE_URL"] ||= "sqlite::memory:"
DB = begin
  db = Sequel.connect(ENV["DATABASE_URL"])
  db.loggers << Logger.new($stderr) if ENV.key?("RODAUTH_DEBUG")
  Sequel.extension :migration
  require "rodauth/migrations"
  Sequel::Migrator.run(db, "test/migrate")
  db
end


Base = Class.new(Roda)
Base.opts[:check_dynamic_arity] = Base.opts[:check_arity] = :warn
Base.plugin :flash
Base.plugin :render, views: "test/views", :layout_opts=>{:path=>'test/views/layout.str'}
Base.plugin(:not_found){raise "path #{request.path_info} not found"}
Base.plugin :common_logger if ENV.key?("RODAUTH_DEBUG")

require "roda/session_middleware"
Base.opts[:sessions_convert_symbols] = true
Base.use RodaSessionMiddleware, secret: SecureRandom.random_bytes(64), key: "rack.session"


class Base
  attr_writer :title
end

class SelectAccountTest < Minitest::Test
  include Capybara::DSL
  include Minitest::Hooks
  
  case ENV['RODA_ROUTE_CSRF']
  when 'no'
    USE_ROUTE_CSRF = false
  when 'no-specific'
    USE_ROUTE_CSRF = true
    ROUTE_CSRF_OPTS = {:require_request_specific_tokens=>false}
  else
    USE_ROUTE_CSRF = true
    ROUTE_CSRF_OPTS = {}
  end

  attr_reader :app

  def no_freeze!
    @no_freeze = true
  end

  def app=(app)
    @app = Capybara.app = app
  end

  def rodauth(&block)
    @rodauth_block = block
  end

  def rodauth_opts(type = {})
    opts = type.is_a?(Hash) ? type : {}
    opts[:csrf] = :route_csrf
    opts
  end

  def roda(type=nil, &block)
    app = Class.new(Base)
    app.opts[:unsupported_block_result] = :raise
    app.opts[:unsupported_matcher] = :raise
    app.opts[:verbatim_string_matcher] = true
    rodauth_block = @rodauth_block
    opts = rodauth_opts(type)
    app.plugin(:rodauth, opts) do
      account_password_hash_column :ph
      title_instance_variable :@title
      instance_exec(&rodauth_block)
    end
    app.route(&block)
    app.precompile_rodauth_templates unless @no_precompile
    app.freeze unless @no_freeze
    self.app = app
  end

  def remove_cookie(key)
    page.driver.browser.rack_mock_session.cookie_jar.delete(key)
  end

  def get_cookie(key)
    page.driver.browser.rack_mock_session.cookie_jar[key]
  end

  def set_cookie(key, value)
    page.driver.browser.rack_mock_session.cookie_jar[key] = value
  end

  def login(opts={})
    visit(opts[:path]||'/login') unless opts[:visit] == false
    fill_in 'Login', :with=>opts[:login] || 'foo@example.com'
    fill_in 'Password', :with=>opts[:pass] || '0123456789'
    click_button 'Login'
  end

  def add_account(opts={})
    visit(opts[:path]||"/add-account") unless opts[:visit] == false
    fill_in 'Login', :with=>opts[:login] || 'foo2@example.com'
    fill_in 'Password', :with=>opts[:pass] || '0123456789'
    click_button 'Login'
  end

  def logout
    visit '/logout'
    click_button 'Logout'
  end

  def around
    DB.transaction(:rollback=>:always, :savepoint=>true, :auto_savepoint=>true) do
      # 1 user
      hash = BCrypt::Password.create("0123456789", cost: BCrypt::Engine::MIN_COST)
      DB[:accounts].insert(email: "foo@example.com", status_id: 2, ph: hash)

      # 2 user
      hash = BCrypt::Password.create("0123456789", cost: BCrypt::Engine::MIN_COST)
      DB[:accounts].insert(email: "foo2@example.com", status_id: 2, ph: hash)
      super
    end
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

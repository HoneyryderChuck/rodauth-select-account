# frozen-string-literal: true

module Rodauth
  Feature.define(:select_account) do
    depends :login

    # add-account
    notice_flash "You have added a new account", "add_account"
    error_flash "There was an error adding the new account", "add_account"
    error_flash "Please add account to continue", "require_add_account"
    view "add-account", "Add Account", "add_account"
    before "add_account"
    after "add_account"
    button "Add Account", "add_account"
    redirect "add_account"

    # select-account
    notice_flash "You have selected an account"
    error_flash "There was an error selecting the account"
    error_flash "Please select account to continue", "require_select_account"
    before
    after
    redirect
    view "select-account", "Select Account"

    session_key :selected_account_key, :selected_account_id
    session_key :accounts_key, :accounts
    session_key :add_account_redirect_session_key, :add_account_redirect
    session_key :select_account_redirect_session_key, :select_account_redirect
    auth_value_method :require_selected_account_cookie_key, "_require_selected_account"
    auth_value_method :accounts_cookie_key, "_accounts"
    auth_value_method :accounts_cookie_options, {}.freeze
    auth_value_method :accounts_cookie_interval, 14 * 60 * 60 * 24 # 14 days
    auth_value_method :require_selected_account_cookie_interval, 60 * 5 # 5 minutes
    auth_value_method :no_account_error_status, 409
    auth_value_method :select_account_required_error_status, 403
    auth_value_method :add_account_required_error_status, 403
    translatable_method :no_account_message, "could not select account"

    def accounts_in_session
      @accounts_in_session ||= _get_accounts_in_session
    end

    def require_login_redirect
      redirect_uri = super

      return redirect_uri unless request.path == select_account_path && (login = param_or_nil(login_param))

      redirect_uri = URI(redirect_uri)
      redirect_uri.query = [redirect_uri.query, "#{login_param}=#{login}"].join("&")
      redirect_uri.to_s
    end

    def require_select_account
      # whether an account has been selected for a certain workflow will be driven by a short-lived
      # cookie, which will hopefully be active during the duration of account selection
      opts = Hash[accounts_cookie_options]
      opts[:path] = "/" unless opts.key?(:path)
      if request.cookies[require_selected_account_cookie_key]
        ::Rack::Utils.delete_cookie_header!(response.headers, require_selected_account_cookie_key, opts)
        return
      end

      opts[:value] = true
      opts[:expires] = Time.now + require_selected_account_cookie_interval
      opts[:httponly] = true unless opts.key?(:httponly)
      opts[:secure] = true unless opts.key?(:secure) || !request.ssl?

      ::Rack::Utils.set_cookie_header!(response.headers, require_selected_account_cookie_key, opts)

      # should redirect to the accounts page, and set this as the page to return to
      redirect_uri = request.fullpath if request.get?
      set_session_value(select_account_redirect_session_key, redirect_uri)
      set_redirect_error_status(select_account_required_error_status)
      set_redirect_error_flash require_select_account_error_flash
      redirect select_account_path
    end

    def skip_login_field_on_login?
      return super unless param_or_nil(login_param) && !field_error(login_param)

      @valid_login_entered = true
      true
    end

    private

    # when selecting an account and requiring login, you'll want the user to go back to where it was
    # before selecting accounts
    def login_after_select_account_required
      set_session_value(login_redirect_session_key, remove_session_value(select_account_redirect_session_key))
      set_redirect_error_status(login_required_error_status)
      set_redirect_error_flash require_login_error_flash
      redirect require_login_redirect
    end

    # when selecting an account and requiring login, you'll want the user to go back to where it was
    # before selecting accounts
    def add_account_after_select_account_required
      set_session_value(add_account_redirect_session_key, remove_session_value(select_account_redirect_session_key))
      set_redirect_error_status(add_account_required_error_status)
      set_redirect_error_flash require_add_account_error_flash
      redirect(add_account_path + "?#{login_param}=#{param(login_param)}")
    end

    def after_login
      super
      _set_account_in_cookie
    end

    def _after_add_account
      _set_account_in_cookie
    end

    def session
      core_session = super
      account_value = core_session[selected_account_key]

      return core_session unless account_value

      (core_session[accounts_key] ||= {})[account_value.to_s] ||= {}
    end

    def update_session
      # clear_session
      set_session_value(session_key, account_session_value)
    end

    def set_session_value(key, value)
      return super unless key == session_key

      full_scope = method(:session).super_method.call
      full_scope[selected_account_key] = value
      super
    end

    def authenticated_session?(account_id); end

    def _get_accounts_in_session
      ds = account_ds(_get_account_ids_in_session_and_cookies)
      ds = ds.where(account_session_status_filter) unless skip_status_checks?
      ds
    end

    def _get_account_ids_in_session_and_cookies
      (_account_ids_from_session + _account_ids_from_cookie).uniq.map(&:to_i)
    end

    def _account_ids_from_session
      account_ids = method(:session).super_method.call[accounts_key]
      return [] unless account_ids

      account_ids.reject do |_, session|
        session.nil? || session.empty?
      end.keys.map(&:to_i)
    end

    def _account_ids_from_cookie
      if (in_cookies = request.cookies[accounts_cookie_key])
        in_cookies.split(",").map(&:to_i)
      else
        []
      end
    end

    def _set_account_in_cookie
      accounts_cookie = _account_ids_from_cookie

      return if accounts_cookie.include?(account_id)

      accounts_cookie << account_id

      opts = Hash[accounts_cookie_options]
      opts[:value] = accounts_cookie.join(",")
      opts[:expires] = Time.now + accounts_cookie_interval
      opts[:path] = "/" unless opts.key?(:path)
      opts[:httponly] = true unless opts.key?(:httponly)
      opts[:secure] = true unless opts.key?(:secure) || !request.ssl?
      ::Rack::Utils.set_cookie_header!(response.headers, accounts_cookie_key, opts)
    end

    def template_path(page)
      path = File.join(File.dirname(__FILE__), "../../../templates", "#{page}.str")
      return super unless File.exist?(path)

      path
    end

    route(:select_account) do |r|
      login_after_select_account_required if accounts_in_session.empty?
      before_select_account_route

      r.get do
        select_account_view
      end

      r.post do
        login_after_select_account_required unless logged_in?

        catch_error do
          @account = accounts_in_session.where(login_column => param(login_param)).first

          throw_error_status(no_account_error_status, login_param, no_account_message) unless @account

          unless _account_ids_from_session.include?(account_session_value)
            # but he has no acknowledged session, redirect to /add-account
            add_account_after_select_account_required
          end

          transaction do
            before_select_account
            # has a valid session, update session
            update_session
            after_select_account
          end
          set_notice_flash select_account_notice_flash
          redirect(select_account_redirect)
        end

        set_error_flash select_account_error_flash
        redirect(remove_session_value(select_account_redirect_session_key) || default_redirect)
      end
    end

    # /add-account
    route(:add_account) do |r|
      require_account
      before_add_account_route

      r.get do
        set_session_value(add_account_redirect_session_key, request.referer) if login_return_to_requested_location?
        add_account_view
      end

      r.post do
        # This is a copy of the login routine
        skip_error_flash = false
        view = :add_account_view

        catch_error do
          # this instruction will load the new account
          unless account_from_login(param(login_param))
            throw_error_status(no_matching_login_error_status, login_param, no_matching_login_message)
          end

          # this will add the same attempt constraints as login has
          before_login_attempt

          throw_error_status(unopen_account_error_status, login_param, unverified_account_message) unless open_account?

          if use_multi_phase_login?
            @valid_login_entered = true
            view = :multi_phase_login_view

            unless param_or_nil(password_param)
              after_login_entered_during_multi_phase_login
              skip_error_flash = true
              next
            end
          end

          unless password_match?(param(password_param))
            after_login_failure
            throw_error_status(login_error_status, password_param, invalid_password_message)
          end

          transaction do
            before_add_account
            login_session(accounts_key)
            after_add_account
          end
          set_notice_flash add_account_notice_flash
          redirect(remove_session_value(add_account_redirect_session_key) || add_account_redirect)
        end

        set_error_flash add_account_error_flash unless skip_error_flash
        send(view)
      end
    end
  end
end

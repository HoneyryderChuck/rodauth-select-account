# frozen-string-literal: true

module Rodauth
  Feature.define(:select_account) do
    depends :login

    # add-account
    notice_flash "You have added a new account", "add_account"
    error_flash "There was an error adding the new account", "add_account"
    view "add-account", "Add Account", "add_account"
    before "add_account"
    after "add_account"
    button "Add Account", "add_account"
    redirect "add_account"

    # select-account
    notice_flash "You have selected an account"
    error_flash "There was an error selecting the account"
    before
    after
    redirect
    
    auth_value_method :no_account_error_status, 409
    translatable_method :no_account_message, "could not select account"


    def accounts_in_session
      @accounts_in_session ||= begin
        full_scope = method(:session).super_method.call
        account_ids = full_scope["accounts"].values.map{|sess| sess[session_key] }
        ds = account_ds(account_ids)
        ds = ds.where(account_session_status_filter) unless skip_status_checks?
        ds
      end
    end

    private

    def session
      core_session = super
      account_value = core_session["selected_account_value"]

      return core_session unless account_value

      (core_session["accounts"] ||= {})[account_value.to_s] ||= {}
    end

    def update_session
      # clear_session
      set_session_value(session_key, account_session_value)
    end

    def set_session_value(key, value)
      return super unless key == session_key

      full_scope = method(:session).super_method.call
      full_scope["selected_account_value"] = value
      super
    end

    route(:select_account) do |r|
      require_account
      before_select_account_route

      r.post do
        catch_error do
          @account = accounts_in_session.where(login_column => param(login_param)).first

          unless @account
            throw_error_status(no_account_error_status, login_param, no_account_message)
          end

          transaction do
            before_select_account

            # if user is not logged in, pre-fill /login form with selected account
            # if user is logged in, but he has no acknowledged session, redirect to /add-account
            # if user is logged in and has a valid session, update session
            update_session
            after_select_account
          end
          set_notice_flash select_account_notice_flash
          redirect(select_account_redirect)
        end

        set_error_flash select_account_error_flash
        redirect(default_redirect)
      end
    end

    # /add-account
    route(:add_account) do |r|
      require_account
      before_add_account_route

      r.get do
        add_account_view
      end

      r.post do
        # This is a copy of the login routine
        skip_error_flash = false
        view = :add_account

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
            login_session("password")
            after_add_account
          end
          set_notice_flash add_account_notice_flash
          redirect(add_account_redirect)
        end

        set_error_flash add_account_error_flash unless skip_error_flash
        send(view)
      end
    end
  end
end

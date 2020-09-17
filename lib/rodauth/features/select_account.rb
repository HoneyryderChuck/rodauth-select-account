# frozen-string-literal: true

module Rodauth
  Feature.define(:select_account) do
    private

    def session
      core_session = super
      account_value = core_session['selected_account_value']

      return core_session unless account_value

      (core_session['accounts'] ||= {})[account_value.to_s] ||= {}
    end

    def update_session
      # clear_session
      set_session_value(session_key, account_session_value)
    end

    def set_session_value(key, value)
      return super unless key == session_key

      full_scope = method(:session).super_method.call
      full_scope['selected_account_value'] = value
      super
    end
  end
end

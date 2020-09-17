# frozen_string_literal: true

require_relative "test_helper"

class RodauthSelectAccountLoginTest < SelectAccountTest
  def test_select_account_login_logout
    rodauth do
      enable :select_account, :login, :logout
    end
    roda do |r|
      r.rodauth

      next unless rodauth.logged_in?

      r.root { view content: "Logged In" }
    end

    visit "/login"
    assert page.title == "Login"
    assert page.find_by_id("password")[:autocomplete] == "current-password"

    login(login: "foo@example2.com", visit: false)
    assert page.find("#error_flash").text == "There was an error logging in"
    assert page.html.include?("no matching login")
    assert page.all("[type=email]").first.value == "foo@example2.com"

    login(pass: "012345678", visit: false)
    assert page.find("#error_flash").text == "There was an error logging in"
    assert page.html.include?("invalid password")

    fill_in "Password", with: "0123456789"
    click_button "Login"
    assert page.current_path == "/"
    assert page.find("#notice_flash").text == "You have been logged in"
    assert page.html.include?("Logged In")

    logout
    assert page.find("#notice_flash").text == "You have been logged out"
    assert page.current_path == "/login"
  end
end

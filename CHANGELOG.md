# CHANGELOG

## master

## 0.1.3

* allow setting `require_selected_account_cookie_interval` and `accounts_cookie_interval` to `nil` in order to set the managed cookies as "Session Cookies" (i.e. getting wiped out on browser close).

## 0.1.2

point release to update project links in rubygems.

## 0.1.1

Updating integration with `rodauth-i18n`, which changed the setup for `v0.2.0`.

## 0.1.0

Support for internationalization (I18n) by hooking up with [rodauth-i18n](https://github.com/janko/rodauth-i18n). Shipping translation for english under `locales/` dir.

## 0.0.4

Cookies used for selected account are now secure by default (httponly on, secure if request is TLS-enabled);

Cookie path is now "/" by default.

## 0.0.3

bugfix: fixing calls to the view helpers when in multi-phase login mode.

## 0.0.2

bugfix: added missing form templates.

## 0.0.1

Initial draft, all features added.

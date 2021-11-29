# frozen_string_literal: true

require "rodauth"

require "rodauth/select-account/version"

Rodauth::I18n.directories << File.expand_path(File.join(__dir__, "..", "..", "locales")) if defined?(Rodauth::I18n)

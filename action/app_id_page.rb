#encoding: utf-8

require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/app_id_dialog"

class AppIdPage 
  include ConfigParam
  include WebdriverHelper
  include AppIdDialog

  def initialize(options = {}) 
    raise "Must pass a hash containing ':user'" if not options.is_a?(Hash) or not options.has_key?(:user) 
    raise "Must pass a hash containing ':driver'" if not options.is_a?(Hash) or not options.has_key?(:driver) 
    if not options.has_key?(:base_url)
      @base_url = $base_url
    else
      @base_url = options.delete(:base_url)
    end

    @driver = options.delete(:driver)
    @data_user = options.delete(:user)
    @user_id = @data_user.delete(:id)
    @user_password = @data_user.delete(:password)

    @sign_in_page = SignInPage.new :driver => @driver, :user => {:id => @user_id.to_s, :password => @user_password.to_s }
  end

  def select_signing_key(options = {}) # select the unlocked one by default
    raise "Must pass a hash containing ':platform'" if not options.is_a?(Hash) or not options.has_key?(:platform)
    raise "Must pass a hash containing ':signingkey_name'" if not options.is_a?(Hash) or not options.has_key?(:signingkey_name)
    platform, signingkey_name = options.delete(:platform), options.delete(:signingkey_name)

  end

  


end
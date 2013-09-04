#encoding: utf-8

require_relative '../util/dialog_locator/header_footer_locator'
require_relative '../util/dialog_locator/sign_in_github_locator'
require_relative '../util/dialog_locator/sign_in_locator'
require_relative '../util/webdriver_helper'
require_relative '../util/config_param'

class SignInPage
    include SignInLocator
    include SignInGithubLocator
    include WebdriverHelper
    include ConfigParam
    include HeaderFooterLocator

    attr_reader :user, :base_url
    
    def initialize(options = {})
        puts "+ <action> initialize SignInPage --- begin"
        raise "Must pass a hash containing ':user'" if not options.is_a?(Hash) or not options.has_key?(:user) 
        raise "Must pass a hash containing ':driver'" if not options.is_a?(Hash) or not options.has_key?(:driver) 
        if not options.has_key?(:base_url)
          @base_url = $base_url
        else
          @base_url = options.delete(:base_url)
        end
        @driver = options.delete(:driver)
        @driver.manage.window.maximize
        @user = options.delete(:user)
        @user_id = @user.delete(:id)
        @user_password = @user.delete(:password)

        @already_signed_in = false
        puts "+ <action> initialize SignInPage --- end"
    end

    def sign_in_with_adobe_id
        puts "+ <action> Sign In with Adobe ID --- begin"
        puts "+ <action>     id:       #{@user_id}"

        go_to_page :sign_in, @base_url
        sleep 5
        change_element_type_by_id :id => 'person_email', :to_type => 'text'
        sign_in_locator(:id_textinput).send_keys(@user_id)
        sign_in_locator(:password_textinput).send_keys(@user_password)
        sign_in_locator(:sign_in_btn).click
        @already_signed_in = true
        sleep 5
        puts "+ <action> Sign In with Adobe ID --- end"
    end
    
    def link_sign_in_with_github_id(id, password)
      sign_in_github_locator(:username_or_email).send_keys(id)
      sign_in_github_locator(:password).send_keys(password)
      sign_in_github_locator(:sign_in_btn).click
      sleep 5
    end

    def sign_in_with_github_id
        puts "+ <action> sign_in_with_Github_ID --- begin"
        puts "+ <action> with id: #{@user_id}"

        go_to_page :sign_in, @base_url
        sign_in_locator(:sign_in_with_github_btn).click
        sleep 5
        sign_in_github_locator(:username_or_email).send_keys(@user_id)
        sign_in_github_locator(:password).send_keys(@user_password)
        sign_in_github_locator(:sign_in_btn).click
        @already_signed_in = true
        sleep 5
        puts "+ <action> sign_in_with_Github_ID --- end"
    end

    # By forget password with valid or invalid email address, and return the message
    def forget_password_and_return_message
        puts "+ <action> forget_password --- begin"
        sleep 3
        go_to_page :sign_in, @base_url
        sign_in_locator(:forgot_my_password_link).click
        sleep 2
        sign_in_locator(:forgot_password_email_input).send_keys(@user_id)
        sign_in_locator(:forgot_password_reset_btn).click
        sleep 5
        message = sign_in_locator(:message).text
        puts "+ <action> forget_password --- end"
        return message
    end

    def make_sure_sign_in
      sign_in_with_adobe_id unless @already_signed_in
    end
    
end
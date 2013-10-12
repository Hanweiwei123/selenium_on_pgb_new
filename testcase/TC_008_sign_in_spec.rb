#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative '../action/sign_in_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/sign_in_locator'
require_relative '../util/dialog_locator/sign_in_github_locator'
require_relative '../util/dialog_locator/header_footer_locator'

# This TC describes: 
#   situations: 
#       Sign in with Adobe ID
#       Sign in with Github ID
#       Forgot password
#       Didn't receive confirmation 
describe "TC_008: Sign in" do
    include SignInLocator
    include ConfigParam
    include WebdriverHelper
    include HeaderFooterLocator

    before(:all) do
        #mixin init function in ConfigParam
        init
        @order_of_it = WebdriverHelper::Counter.new
        @name_screenshot = "TC_008_IT_"
        @base_url = base_url
        @driver =driver
        @driver.manage.window.maximize
        @driver.manage.timeouts.implicit_wait = 30
    end

    after(:each) do  # Take screenshot in case of failure
        @name_screenshot += @order_of_it.inc.to_s
        begin
            if example.exception != nil
                take_screenshot_with_name @name_screenshot
            end
        end
    end

    after(:all) do 
        @driver.quit
    end

    context "--- with GitHub ID" do
        it "IT_001: Sign in successfully when use valid appropriate account" do 
            @base_url = 'https://buildstage.phonegap.com'
            @sign_in_page = SignInPage.new(
                    :driver => @driver, 
                    :base_url => @base_url, 
                    :user => {:id => $data[:user][$lang][:github_id_only][:id], :password => $data[:user][$lang][:github_id_only][:password]} )
            @sign_in_page.sign_in_with_github_id
            sleep 5
            @driver.current_url.should == @base_url + $data[:url][:sign_in_successfully]
            sign_out
        end
    end

    context "--- with Adobe ID " do
        it "IT_002: Sign in successfully when use valid appropriate account" do
            @sign_in_page = SignInPage.new(
                    :driver => @driver, 
                    :base_url => @base_url, 
                    :user => {:id => $data[:user][$lang][:adobe_id_free_001][:id], :password => $data[:user][$lang][:adobe_id_free_001][:password]} )
            @sign_in_page.sign_in_with_adobe_id
            sleep 5
            @driver.current_url.should == @base_url + $data[:url][:sign_in_successfully]
            sign_out
        end

        it "IT_003: Got an error message when use invalid email or password" do
            @sign_in_page = SignInPage.new(
                    :driver => @driver, 
                    :base_url => @base_url, 
                    :user => {:id => $data[:user][$lang][:invalid_user][:id], :password => $data[:user][$lang][:invalid_user][:password]} )
            @sign_in_page.sign_in_with_adobe_id
            sleep 5
            # error message should match the expecation
            sign_in_locator(:error_message_box).text.should eql $data[:str][$lang][:not_found_in_database]
        end
    end

    context "--- I forgot my password" do 
        it "IT_004: Got an tip message about instruments when use valid email address" do
            @sign_in_page = SignInPage.new(
                    :driver => @driver, 
                    :base_url => @base_url, 
                    :user => {:id => $data[:user][$lang][:adobe_id_free_001][:id], :password => "" } )
            @tips = @sign_in_page.forget_password_and_return_message
            @tips.should eql $data[:str][$lang][:passwords_send_instructions]
        end

        it "IT_005: Got an error message when use invalid email address" do 
            @sign_in_page = SignInPage.new(
                    :driver => @driver, 
                    :base_url => @base_url, 
                    :user => {:id => $data[:user][$lang][:invalid_user][:id], :password => "" } )
            @tips = @sign_in_page.forget_password_and_return_message
            @tips.should eql $data[:str][$lang][:PGB_email_not_found]
        end
    end

end

#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative '../action/register_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/register_locator'
require_relative '../util/dialog_locator/header_footer_locator'

# This TC describes
#   situations trying to register with Adobe ID to sign in.
describe "TC_004: Register as free plan with Adobe ID" do
    include RegisterLocator
    include ConfigParam
    include WebdriverHelper
    include HeaderFooterLocator

    before(:all) do
        init
        @order_of_it = WebdriverHelper::Counter.new
        @name_screenshot = "TC_004_IT_"
        @base_url = base_url
        @driver = driver

        @register_page = RegisterPage.new :driver => @driver
        @register_page.choose_your_plan('free_plan')
        @register_page.choose_how_to_sign_in('register_adobeid')
        @driver.switch_to.frame(0)
        sleep 5
    end

    after(:all) do
        @driver.quit
    end

    after(:each) do  # Take screenshot in case of failure
        @name_screenshot += @order_of_it.inc.to_s
        if example.exception != nil
            take_screenshot_with_name @name_screenshot
        end
    end

    context "---- Adobe ID" do
        it "IT_001: Got an error message with invalid Adobe ID (Email Address)" do
            fill_in register_locator(:adobe_id_frame_adobe_id_input), :with => $data[:user][$lang][:invalid_user][:id]
            fill_in register_locator(:adobe_id_frame_password_input), :with => $data[:user][$lang][:invalid_user][:password]
            register_locator(:adobe_id_frame_sign_in_btn).click
            register_locator(:do_not_match_warning).text.should eql $data[:str][$lang][:PGB_Adobe_id_and_password_not_match]
        end

        it "IT_002: Got an error message with wrong password" do
            fill_in register_locator(:adobe_id_frame_adobe_id_input), :with => $data[:user][$lang][:invalid_user][:id]
            fill_in register_locator(:adobe_id_frame_password_input), :with => $data[:user][$lang][:invalid_user][:password]
            register_locator(:adobe_id_frame_sign_in_btn).click
            register_locator(:do_not_match_warning).text.should eql $data[:str][$lang][:PGB_Adobe_id_and_password_not_match]
        end

        it "IT_003: Sign in successfully with valid appropriate email and password " do
            fill_in register_locator(:adobe_id_frame_adobe_id_input), :with => $data[:user][$lang][:adobe_id_free_001][:id]
            fill_in register_locator(:adobe_id_frame_password_input), :with => $data[:user][$lang][:adobe_id_free_001][:password]
            register_locator(:adobe_id_frame_sign_in_btn).click
            # wait_for_page_load(@base_url + $data[:url][:sign_in_successfully])
            sleep 15
            @driver.current_url.should eql @base_url + $data[:url][:sign_in_successfully]
        end
    end
end

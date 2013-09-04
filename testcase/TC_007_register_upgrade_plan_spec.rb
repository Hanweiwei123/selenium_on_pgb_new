#encoding: utf-8

# Please ignore this one. 
# For there are some account-related issues we are still working on. 
# It will be ok later. 

require 'rubygems'
require 'rspec'

require_relative '../action/sign_in_page'
require_relative '../action/new_app_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/new_app_locator'
require_relative '../util/dialog_locator/register_locator'

describe "TC_007: Register -> upgrade plan (Free -> Paid)" do 
    include ConfigParam
    include WebdriverHelper
    include NewAppLocator
    include RegisterLocator

    before(:all) do 
        init
        @order_of_it = WebdriverHelper::Counter.new
        @name_screenshot = "TC_007_IT_"
        @base_url = base_url
        @driver = driver
        @new_app_page = NewAppPage.new(
                    :base_url => @base_url,
                    :driver => @driver,
                    :user => {:id => $data[:user][$lang][:adobe_id_for_upgrade_purpose_support_area][:id], :password => $data[:user][$lang][:adobe_id_for_upgrade_purpose_support_area][:password] })
        @new_app_page.make_sure_apps_page
    end

    before(:each) do 
        begin
            sleep 5
        end until @driver.current_url == @base_url + $data[:url][:sign_in_successfully]
        @new_app_page.new_app_with_zip; sleep 10
    end

    after(:each) do  # Take screenshot in case of failure
        @name_screenshot += @order_of_it.inc.to_s
        begin
            if example.exception != nil
                take_screenshot_with_name @name_screenshot
            end
        ensure
            @driver.quit
        end
    end

    it "IT_001: page does direct to 'http://creative.adobe.com' page, when select the 'Creative Cloud Membership' " do 
        if @new_app_page.new_app_btn_display?
            new_app_locator(:new_app_btn).click; sleep 5
            new_app_locator(:private_repo_tab).click
        end
        new_app_locator(:upgrade_now_link).click
        begin
            sleep 5
        end until @driver.current_url == @base_url + $data[:url][:register_page]
        register_locator(:paid_plan_link).click;  sleep 10
        @driver.switch_to.frame(0);  sleep 5
        fill_in register_locator(:adobe_id_frame_adobe_id_input), :with => $data[:user][$lang][:adobe_id_for_upgrade_purpose_support_area][:id]
        fill_in register_locator(:adobe_id_frame_password_input), :with => $data[:user][$lang][:adobe_id_for_upgrade_purpose_support_area][:password]
        register_locator(:adobe_id_frame_sign_in_btn).click;  sleep 5
        @driver.switch_to.default_content
        puts "+ after @driver.switch_to.default_content"
        register_locator(:payment_cc_plan).click;  sleep 5
        @driver.current_url.should eql "https://creative.adobe.com/plans"
    end

end
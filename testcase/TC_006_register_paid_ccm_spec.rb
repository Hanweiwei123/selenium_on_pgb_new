#encoding: utf-8

require 'rspec'
require 'rubygems'

require_relative '../action/new_app_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/register_locator'
require_relative '../util/dialog_locator/header_footer_locator'

describe "TC_006: Register paid CCM account" do 
    include RegisterLocator
    include ConfigParam
    include WebdriverHelper
    include HeaderFooterLocator

    before(:all) do 
        init
        @order_of_it = WebdriverHelper::Counter.new
        @name_screenshot = "TC_006_IT_"
        @base_url = base_url
    end

    after(:all) do 
        # webhelper_delete_all_apps($data[:user][$lang][:ccm_acnt_001][:id], $data[:user][$lang][:ccm_acnt_001][:password])
        webhelper_delete_all_apps($data[:user][$lang][:ccm_acnt_002][:id], $data[:user][$lang][:ccm_acnt_002][:password])
        # webhelper_delete_all_apps($data[:user][$lang][:ccm_acnt_003][:id], $data[:user][$lang][:ccm_acnt_003][:password])
    end

    before(:each) do
        @driver = driver
        @driver.manage.window.maximize
        @driver.manage.timeouts.implicit_wait = 30
        @driver.get path_format_locale("/plans/paid",@base_url); sleep 5
        @driver.switch_to.frame(0)
        puts "+ after driver.switch_to.frame(0)..."
    end

    after(:each) do # Take screenshot in case of failure
        @name_screenshot += @order_of_it.inc.to_s
        begin
            if example.exception != nil
                take_screenshot_with_name @name_screenshot
            end
        ensure
            @driver.quit
        end
    end

    it "IT_001: It could create two private apps when using the paid ccm account: dil40562+teamfra1128@adobetest.com" do 
        sleep 5
        fill_in register_locator(:adobe_id_frame_adobe_id_input), :with => $data[:user][$lang][:ccm_acnt_002][:id]
        fill_in register_locator(:adobe_id_frame_password_input), :with => $data[:user][$lang][:ccm_acnt_002][:password]
        register_locator(:adobe_id_frame_sign_in_btn).click;  sleep 5
        @driver.switch_to.default_content
        register_locator(:payment_cc_plan).click; sleep 10 # 29.99/mo
        @driver.current_url.should eql 'https://creative.adobe.com/plans'
        @driver.get @base_url
        @new_app_page = NewAppPage.new(
                    :driver => @driver, 
                    :base_url => @base_url,
                    :user => { :id => $data[:user][$lang][:ccm_acnt_002][:id], :password => $data[:user][$lang][:ccm_acnt_002][:password] })
        # try to create 2 private apps 

        @new_app_page.new_app_with_zip; sleep 10
        @new_app_page.new_app_with_zip; sleep 10
        app_count_after = @new_app_page.number_of_existing_apps
        puts "+ app_count_after: #{app_count_after}"
        app_count_after.should eql 2
    end

end

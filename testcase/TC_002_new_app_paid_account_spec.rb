#encoding: utf-8

require 'rspec'
require 'rubygems'

require_relative '../action/new_app_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/new_app_locator'
require_relative '../util/dialog_locator/header_footer_locator'

describe "TC_002: New apps with paid account" do
    include NewAppLocator
    include ConfigParam
    include WebdriverHelper
    include HeaderFooterLocator

    before(:all) do
        init
        @order_of_it = WebdriverHelper::Counter.new
        @name_screenshot = "TC_002_IT_"
        @base_url = base_url
        @driver = driver
        @new_app_page = NewAppPage.new(
                    :driver => @driver, 
                    :base_url => @base_url,
                    :user => {:id => $data[:user][$lang][:adobe_id_paid_001][:id], :password => $data[:user][$lang][:adobe_id_paid_001][:password]})
        sleep 3
    end

    after(:all) do
        begin 
            webhelper_delete_all_apps $data[:user][$lang][:adobe_id_paid_001][:id], $data[:user][$lang][:adobe_id_paid_001][:password]
        ensure
            @driver.quit
        end
    end

    after(:each) do  # Take screenshot in case of failure
        @name_screenshot += @order_of_it.inc.to_s
        if example.exception != nil
            take_screenshot_with_name @name_screenshot
        end
    end

    it "IT_001: the number of apps did not equal to 0 after creating an private app by uploading a .zip file" do 
        @new_app_page.new_app_with_zip

        sleep 5 
            
        @app_count_after = @new_app_page.number_of_existing_apps
        @first_app_id_after = @new_app_page.first_app_id
        puts "+app_count_after: #{@app_count_after}"
        puts "+first_app_id_after: #{@first_app_id_after}"
 
        @app_count_after.should_not eql 0
    end

    it "IT_002: the number of apps did not stay the same after creating the second private app"  do 
        sleep 5
        @app_count_before = @new_app_page.number_of_existing_apps
        @first_app_id_before = @new_app_page.first_app_id
        puts "+app_count_before: #{@app_count_before}"
        puts "+first_app_id_before: #{@first_app_id_before}"

        @return_value = @new_app_page.new_app_with_zip  
        
        sleep 5 

        @app_count_after = @new_app_page.number_of_existing_apps
        @first_app_id_after = @new_app_page.first_app_id
        puts "+app_count_after: #{@app_count_after}"
        puts "+first_app_id_after: #{@first_app_id_after}"
        
        @app_count_after.should eql @app_count_before + 1
    end    

end

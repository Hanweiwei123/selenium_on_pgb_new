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
        @driver.manage.timeouts.implicit_wait = 30
        @new_app_page = NewAppPage.new(
                    :driver => @driver, 
                    :base_url => @base_url,
                    :user => {:id => $data[:user][$lang][:adobe_id_paid_001][:id], :password => $data[:user][$lang][:adobe_id_paid_001][:password]})
        sleep 3
    end

    after(:all) do
        webhelper_delete_all_apps $data[:user][$lang][:adobe_id_paid_001][:id], $data[:user][$lang][:adobe_id_paid_001][:password]
        @driver.quit
    end

    after(:each) do  # Take screenshot in case of failure
        @name_screenshot += @order_of_it.inc.to_s
        if example.exception != nil
            take_screenshot_with_name @name_screenshot
        end
    end

    it "IT_001: the number of apps did not equal to 0 after creating an private app by uploading a .zip file" do
        puts "IT_" + @order_of_it.to_s
        @new_app_page.new_app_with_zip
        sleep 5
        app_count_after = @new_app_page.number_of_existing_apps
        @new_app_page.first_app_id
        app_count_after.should_not eql 0
    end

    it "IT_002: the number of apps did not stay the same after creating the second private app"  do
        puts "IT_" + @order_of_it.to_s
        sleep 2
        app_count_before = @new_app_page.number_of_existing_apps
        first_app_id_before = @new_app_page.first_app_id

        @new_app_page.new_app_with_zip; sleep 5

        app_count_after = @new_app_page.number_of_existing_apps
        first_app_id_after = @new_app_page.first_app_id

        app_count_after.should eql app_count_before + 1
        first_app_id_after.should_not eql first_app_id_before
    end  
    
     it "IT_003: the number of apps was not the same as before, after delete one app" do
        puts "IT_" + @order_of_it.to_s
  
        app_count_before = @new_app_page.number_of_existing_apps
        first_app_id_before = @new_app_page.first_app_id
  
        # delete the first_app_id_after
        new_app_locator(:delete_app_btn).click
        new_app_locator(:delete_app_msg).text.should eql $data[:str][$lang][:delete_app_msg]
        new_app_locator(:delete_app_no).click
        new_app_locator(:delete_app_btn).click
        new_app_locator(:delete_app_yes).click
        sleep 3
        app_count_after = @new_app_page.number_of_existing_apps
        first_app_id_after = @new_app_page.first_app_id
        app_count_after.should eql app_count_before - 1
        first_app_id_after.should_not eql first_app_id_before
  
        # delete the first_app_id_before
        @driver.navigate.refresh; sleep 3
        new_app_locator(:delete_app_btn).click
        new_app_locator(:delete_app_msg).text.should eql $data[:str][$lang][:delete_app_msg]
        new_app_locator(:delete_app_no).click
        new_app_locator(:delete_app_btn).click
        new_app_locator(:delete_app_yes).click
        sleep 3
        app_count_after = @new_app_page.number_of_existing_apps
        app_count_after.should eql app_count_before - 2
    end
    
    it "IT_004: if the number of apps is greater than 25, check the message localized" do
      puts "IT_" + @order_of_it.to_s
      sleep 5
      for i in 1..26 do
        puts "+<the order> is #{i}"
        @new_app_page.new_app_with_zip
        sleep 5
        #new_app_locator(:ready_to_build_btn).click
        #sleep 5
        @new_app_page.number_of_existing_apps
        @new_app_page.first_app_id
      end
      #puts new_app_locator(:app_num_msg).text
      new_app_locator(:app_num_msg).text.should eql $data[:str][$lang][:create_app_mun_error_msg]
    end

end

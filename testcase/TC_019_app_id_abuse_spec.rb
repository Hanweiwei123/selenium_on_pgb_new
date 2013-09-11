#encoding: utf-8

require 'rspec'
require 'rubygems'

require_relative '../action/new_app_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'

describe "TC_019: App Id #Abuse " do
    include NewAppLocator
    include ConfigParam
    include WebdriverHelper
    include HeaderFooterLocator

    before(:all) do 
    	puts "+ <TC_001> before all outer --- begin"
      init
      @order_of_it = WebdriverHelper::Counter.new
      @name_screenshot = "TC_001_IT_"
      @base_url = base_url
      @driver = driver
      @driver.manage.window.maximize

      @new_app_page = NewAppPage.new(
                    :driver => @driver, 
                    :base_url => @base_url,
                    :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password => $data[:user][$lang][:adobe_id_free_002][:password]})
      @new_app_page.new_public_app_with_repo; sleep 5
      @app_id = @new_app_page.first_app_id; 
      new_app_locator(:ready_to_build_btn).click;  sleep 10
      puts "+ <TC_001> before all outer --- end"
    end
    
    after(:all) do 
    	puts "+ <TC_019> after all outer --- begin"
        begin 
            webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
        ensure
            @driver.quit
        end
        puts "+ <TC_019> after all outer --- end"
    end

    after(:each) do  # Take screenshot in case of failure
        @name_screenshot += @order_of_it.inc.to_s

        if example.exception != nil
            take_screenshot_with_name @name_screenshot
        end
    end





end
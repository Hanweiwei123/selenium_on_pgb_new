#encoding: utf-8

require 'rubygems'
require 'rspec'
require 'selenium-webdriver'
require 'yaml'

require_relative "../action/sign_in_page"
require_relative "../action/edit_account_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"

describe "TC_009: signing_key_add_and_unlock_rspec" do 
    include SignInLocator
    include EditAccountLocator
    include ConfigParam
    include WebdriverHelper

    before(:all) do 
        init
        @order_of_it = WebdriverHelper::Counter.new
        @name_screenshot = "TC_009_IT_"
        @base_url = base_url
        @driver = driver # have to start a new instance each time to clean the cache.
        @driver.manage.window.maximize
        @driver.manage.timeouts.implicit_wait = 30
        @driver.execute_script("window.resizeTo(screen.width,screen.height)")

        @edit_account_page = EditAccountPage.new(
            :driver => @driver,
            :base_url => @base_url,
            :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password => $data[:user][$lang][:adobe_id_free_002][:password]} )
    end

    after(:all) do
      webhelper_delete_all_signing_keys($data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password])
      @driver.quit

    end

    after(:each) do  # Take screenshot in case of failure
        @name_screenshot += @order_of_it.inc.to_s
        if example.exception != nil
            take_screenshot_with_name @name_screenshot
        end
    end

    context "--- ADD & UNLOCK signing-key through 'Edit account' page. " do 


        it "IT_001: the new-added iOS signing_key should be locked after adding successfully " do 
            @edit_account_page.add_ios_signing_key "valid"
            @edit_account_page.get_status_of_1st_ios_signing_key.should eql $data[:str][$lang][:apps_signing_key_locked]
        end

        it "IT_002: the above iOS signing Key was unlocked after unlocking it" do
            @edit_account_page.to_unlock_1st_ios_signing_key
            sleep 5
            @edit_account_page.get_status_of_1st_ios_signing_key.should eql $data[:str][$lang][:apps_signing_key_unlocked]
        end

        it "IT_003: the number of iOS signing_keys should be 0 after deleting the one added above " do
           @edit_account_page.delete_1st_ios_signing_key
           sleep 5
           @driver.navigate.refresh; sleep 5
           ea_signing_keys(:signing_keys_tab).click
           is_element_present_by(:xpath,"//*[@id='person-keys']/table[1]/tbody/tr").should eql false
        end
        
        it "IT_004: the new-added Android signing_key should be locked after adding successfully" do
           @edit_account_page.add_android_signing_key "valid"
           @edit_account_page.get_status_of_1st_android_signing_key.should eql $data[:str][$lang][:apps_signing_key_locked]
        end
        
        it "IT_005: the above Adroid signing_key was unlocked after unlocking it" do
           @edit_account_page.to_unlock_1st_android_signing_key
           @edit_account_page.get_status_of_1st_android_signing_key.should eql $data[:str][$lang][:apps_signing_key_unlocked]
        end
        
        it "IT_006: the number of Android signing-key should be 0 after deleting the one added above" do
           @edit_account_page.delete_1st_android_signing_key
           sleep 5
           @driver.navigate.refresh; sleep 5
           ea_signing_keys(:signing_keys_tab).click
           is_element_present_by(:xpath,"//*[@id='person-keys']/table[2]/tbody/tr").should eql false
        end
        
        it "IT_007: the new-added BlackBerry signing_key should be locked after adding successfully" do
           @edit_account_page.add_blackberry_signing_key "valid"
           @edit_account_page.get_status_of_1st_blackberry_signing_key.should eql $data[:str][$lang][:apps_signing_key_locked]
        end
        
        it "IT_008: the above BlackBerry signing_key was unlocked after unlocking it" do
           @edit_account_page.to_unlock_1st_blackberry_signing_key
           @edit_account_page.get_status_of_1st_blackberry_signing_key.should eql $data[:str][$lang][:apps_signing_key_unlocked]
        end
        
        it "IT_009: the number of BlackBerry signing-key should be 0 after deleting the one added above" do
           @edit_account_page.delete_1st_blackberry_signing_key
           sleep 5
           @driver.navigate.refresh; sleep 5
           ea_signing_keys(:signing_keys_tab).click
           is_element_present_by(:xpath,"//*[@id='person-keys']/table[3]/tbody/tr").should eql false
        end

    end

end

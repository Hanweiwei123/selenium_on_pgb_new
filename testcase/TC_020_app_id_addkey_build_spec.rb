#encoding: utf-8

require 'rubygems'
require 'rspec'
require 'timeout'
require "rautomation"

require_relative "../action/new_app_page"
require_relative "../action/app_builds_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/new_app_locator"
require_relative "../util/dialog_locator/app_id_locator"

describe "TC_015: App Details #Builds" do
  include ConfigParam
  include WebdriverHelper
  include NewAppLocator
  include AppIdLocator

  before(:all) do
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_020_IT_"
    #@base_url = base_url
    @base_url = "https://build.phonegap.com"
    @driver = driver
    @download_dir = Dir.home + "/Downloads"
    @driver.manage.window.maximize
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")
    @driver.manage.timeouts.implicit_wait = 30

    @new_app_page = NewAppPage.new :driver => @driver,
                                   :base_url =>@base_url ,
                                   :user => { :id => "shuai.yan@dilatoit.com", :password => "yanshuai110" }
                                   #:user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password =>  $data[:user][$lang][:adobe_id_free_002][:password] }
    @app_build_page = AppBuildsPage.new :driver => @driver,
                                   :base_url =>@base_url ,
                                   :user => { :id => "shuai.yan@dilatoit.com", :password => "yanshuai110" }
                                   #:user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password =>  $data[:user][$lang][:adobe_id_free_002][:password] }
    @new_app_page.new_app_with_zip;  sleep 5
    @app_id = @new_app_page.first_app_id
    new_app_locator(:ready_to_build_btn).click
    sleep 10
    @driver.get @driver.current_url + "\/#{@app_id}\/builds" ;sleep 5
    @current_url = @driver.current_url
    puts "+<current_url> is #{@current_url}";
  end

  after(:all) do
    begin
      #webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
      #webhelper_delete_all_signing_keys $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
      webhelper_delete_all_apps "shuai.yan@dilatoit.com", "yanshuai110"
      webhelper_delete_all_signing_keys "shuai.yan@dilatoit.com", "yanshuai110"
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

  context "Build with locked-keys" do

    it "IT_001: Android error message should be localized" do
      timeout(60) {
        while $data[:str][$lang][:builds_action_pending] == builds(:android_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:android_action).text
        end
      }
      @app_build_page.android_add_signing_key "invalid"
      builds(:android_rebuild).click;  sleep 10
      error_msg = @app_build_page.android_get_error_msg_of_the_signing_key
      error_msg.should eql $data[:str][$lang][:error_msg_android_build_with_locked_signing_key]
    end

    it "IT_002: BlackBerry error message should be localized" do
      timeout(60) {
        while $data[:str][$lang][:builds_action_pending] == builds(:blackberry_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:blackberry_action).text
        end
      }
      @app_build_page.blackberry_add_signing_key "invalid"
      builds(:blackberry_rebuild).click;  sleep 10
      error_msg = @app_build_page.blackberry_get_error_msg_of_the_signing_key
      error_msg.should eql $data[:str][$lang][:error_msg_blackberry_build_with_locked_signing_key]
    end

    it "IT_003: iOS error message should be localized" do
      timeout(60) {
        while $data[:str][$lang][:builds_action_pending] == builds(:ios_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:ios_action).text
        end
      }
      @app_build_page.ios_add_signing_key "invalid"
      builds(:ios_rebuild).click;  sleep 10
      error_msg = @app_build_page.ios_get_error_msg_of_the_signing_key
      error_msg.should eql $data[:str][$lang][:error_msg_ios_build_with_locked_signing_key]
    end

  end

  context "Build with unlocked-keys by incorrect password and check the error message" do

     it "IT_004: iOS error message should be localized" do
       @app_build_page.to_unlock_ios_signing_key "invalid"
       builds(:ios_rebuild).click;  sleep 10
       error_msg = @app_build_page.ios_get_error_msg_of_the_signing_key
       error_msg.should eql $data[:str][$lang][:error_msg_ios_build_with_unlocked_signing_key_with_invalid_psd]
     end

     it "IT_005: Android error message should be localized" do
       @app_build_page.to_unlock_android_signing_key "invalid"
       builds(:android_rebuild).click;  sleep 10
       error_msg = @app_build_page.android_get_error_msg_of_the_signing_key
       error_msg.should eql $data[:str][$lang][:error_msg_android_build_with_unlocked_signing_key_with_invalid_psd]
     end

     it "IT_006: BlackBerry error message should be localized" do
       @app_build_page.to_unlock_blackberry_signing_key "invalid"
       builds(:blackberry_rebuild).click;  sleep 10
       error_msg = @app_build_page.blackberry_get_error_msg_of_the_signing_key
       error_msg.should eql $data[:str][$lang][:error_msg_blackberry_build_with_unlocked_signing_key_with_invalid_psd]
     end

  end

  context "Build with unlocked-keys and download" do

     it "IT_007: should download the >>iOS<< app successfully" do
       @app_build_page.ios_add_signing_key
       @app_build_page.to_unlock_ios_signing_key
       builds(:ios_rebuild).click;  sleep 10
       timeout(120) {
         while $data[:str][$lang][:builds_action_pending] == builds(:ios_action).text do
           @driver.navigate.refresh
           sleep 5
           puts "+ action: " + builds(:ios_action).text
         end
       }
       if builds(:ios_action).text != $data[:str][$lang][:builds_action_error]
         builds(:ios_action).click;  sleep 10
         win = RAutomation::Window.new(:title => /Opening/i)
         if win.exist?
           win.activate; sleep 2; win.send_keys :tab ; sleep 2; win.send_keys :tab ; win.send_keys :enter
         else
           puts "Can not catch the dialog!!!"
         end
         sleep 10
         Dir["#{@download_dir}/*.ipa"].count.should > 0
         system("rm #{@download_dir}/*.ipa")
       else
         error_msg = @app_build_page.ios_get_error_msg_of_the_signing_key
         puts "iOS app was not available. "+error_msg
         1.should_not eql 1
       end
     end

     it "IT_008: should download the >>Android<< app successfully" do
       @app_build_page.android_add_signing_key
       @app_build_page.to_unlock_android_signing_key
       builds(:android_rebuild).click;  sleep 10
       timeout(60) {
         while $data[:str][$lang][:builds_action_pending] == builds(:android_action).text do
           @driver.navigate.refresh
           sleep 5
           puts "+ action: " + builds(:android_action).text
         end
       }
       if builds(:android_action).text != $data[:str][$lang][:builds_action_error]
         builds(:android_action).click;  sleep 10
         win = RAutomation::Window.new(:title => /Opening/i)
         if win.exist?
           win.activate; sleep 2; win.send_keys :tab ; sleep 2; win.send_keys :tab ; win.send_keys :enter
         else
           puts "Can not catch the dialog!!!"
         end
         sleep 10
         Dir["#{@download_dir}/*.apk"].count.should > 0
         system("rm #{@download_dir}/*.apk")
       else
         error_msg = @app_build_page.android_get_error_msg_of_the_signing_key
         puts "Android app was not available. "+error_msg
         1.should_not eql 1
       end
     end

     it "IT_009: should download the >>BlackBerry<< app successfully" do
       @app_build_page.blackberry_add_signing_key
       @app_build_page.to_unlock_blackberry_signing_key
       builds(:blackberry_rebuild).click;  sleep 10
       timeout(120) {
         while $data[:str][$lang][:builds_action_pending] == builds(:blackberry_action).text do
           @driver.navigate.refresh
           sleep 5
           puts "+ action: " + builds(:blackberry_action).text
         end
       }
       if builds(:blackberry_action).text != $data[:str][$lang][:builds_action_error]
         builds(:blackberry_action).click;  sleep 10
         win = RAutomation::Window.new(:title => /Opening/i)
         if win.exist?
           win.activate; sleep 2; win.send_keys :tab ; sleep 2; win.send_keys :tab ; win.send_keys :enter
         else
           puts "Can not catch the dialog!!!"
         end
         sleep 10
         Dir["#{@download_dir}/*.jad"].count.should > 0
         system("rm #{@download_dir}/*.jad")
       else
         error_msg = @app_build_page.blackberry_get_error_msg_of_the_signing_key
         puts "Android app was not available. "+error_msg
         1.should_not eql 1
       end
     end
  end

end

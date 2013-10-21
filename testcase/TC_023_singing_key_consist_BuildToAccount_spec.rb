#encoding: utf-8

require 'rubygems'
require 'rspec'
require 'timeout'
require "rautomation"

require_relative "../action/new_app_page"
require_relative "../action/app_builds_page"
require_relative "../action/edit_account_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/new_app_locator"
require_relative "../util/dialog_locator/app_id_locator"

describe "TC_023: singing_key_consist_BuildToAccount" do
  include ConfigParam
  include WebdriverHelper
  include NewAppLocator
  include AppIdLocator

  before(:all) do
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_023_IT_"
    @base_url = base_url
    #@base_url = "https://buildstage.phonegap.com"
    @driver = driver
    @download_dir = Dir.home + "/Downloads"
    @driver.manage.window.maximize
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")
    @driver.manage.timeouts.implicit_wait = 30

    @new_app_page = NewAppPage.new :driver => @driver,
                                   :base_url =>@base_url ,
                                   :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password =>  $data[:user][$lang][:adobe_id_free_002][:password] }
    @app_build_page = AppBuildsPage.new :driver => @driver,
                                        :base_url =>@base_url ,
                                        :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password =>  $data[:user][$lang][:adobe_id_free_002][:password] }
    @edit_account_page = EditAccountPage.new :driver => @driver,
                                             :base_url => @base_url,
                                             :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password => $data[:user][$lang][:adobe_id_free_002][:password]}

    @new_app_page.new_app_with_zip;  sleep 5
    @app_id = @new_app_page.first_app_id
    new_app_locator(:ready_to_build_btn).click;sleep 5
    @driver.navigate.refresh; sleep 5
    @driver.get @base_url + "\/apps\/#{@app_id}\/builds" ;sleep 5
    @current_url = @driver.current_url
    puts "+<current_url> is #{@current_url}";
  end

  after(:all) do
    webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
    webhelper_delete_all_signing_keys $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
    @driver.quit
  end

  after(:each) do  # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  context "Build with locked-keys" do

    it "IT_001: add iOS signing_key in app_id_build page" do
      timeout(60) {
        while $data[:str][$lang][:builds_action_pending] == builds(:ios_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:ios_action).text
        end
      }
      @app_build_page.ios_add_signing_key "valid"
      @app_build_page.to_unlock_ios_signing_key "valid"
      @app_build_page.ios_add_signing_key "invalid"
      builds(:ios_unlocked_options).attribute('label').should  eql $data[:str][$lang][:apps_signing_key_unlocked]
      builds(:ios_unlocked_first_key).text.should eql $data[:signing_key][:ios][:name_valid]
      builds(:ios_locked_options).attribute('label').should  eql $data[:str][$lang][:apps_signing_key_locked]
      builds(:ios_locked_first_key).text.should eql $data[:signing_key][:ios][:name_invalid]
    end

    it "IT_002: add Android signing_key in app_id_build page" do
      timeout(60) {
        while $data[:str][$lang][:builds_action_pending] == builds(:android_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:android_action).text
        end
      }
      @app_build_page.android_add_signing_key "valid"
      @app_build_page.to_unlock_android_signing_key "valid"
      @app_build_page.android_add_signing_key "invalid"
      builds(:android_unlocked_options).attribute('label').should  eql $data[:str][$lang][:apps_signing_key_unlocked]
      builds(:android_unlocked_first_key).text.should eql $data[:signing_key][:android][:name_valid]
      builds(:android_locked_options).attribute('label').should  eql $data[:str][$lang][:apps_signing_key_locked]
      builds(:android_locked_first_key).text.should eql $data[:signing_key][:android][:name_invalid]
    end

    it "IT_003: add BlackBerry signing_key in app_id_build page" do
      timeout(60) {
        while $data[:str][$lang][:builds_action_pending] == builds(:blackberry_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:blackberry_action).text
        end
      }
      @app_build_page.blackberry_add_signing_key "valid"
      @app_build_page.to_unlock_blackberry_signing_key "valid"
      @app_build_page.blackberry_add_signing_key "invalid"
      builds(:blackberry_unlocked_options).attribute('label').should  eql $data[:str][$lang][:apps_signing_key_unlocked]
      builds(:blackberry_unlocked_first_key).text.should eql $data[:signing_key][:blackberry][:name_valid]
      builds(:blackberry_locked_options).attribute('label').should  eql $data[:str][$lang][:apps_signing_key_locked]
      builds(:blackberry_locked_first_key).text.should eql $data[:signing_key][:blackberry][:name_invalid]
    end

  end

  context "Build with unlocked-keys by incorrect password and check the error message" do

    before (:all) do
      @driver.get @base_url + "\/people\/edit" ;sleep 5
    end

    it "IT_004: check iOS signing_key in edit_account page" do
      @edit_account_page.get_status_of_signing_key($data[:signing_key][:ios][:name_valid] ,"ios").should eql $data[:str][$lang][:apps_signing_key_unlocked]
      @edit_account_page.get_status_of_signing_key($data[:signing_key][:ios][:name_invalid] ,"ios").should eql $data[:str][$lang][:apps_signing_key_locked]
    end

    it "IT_005: check Android signing_key in edit_account page" do
      @edit_account_page.get_status_of_signing_key($data[:signing_key][:android][:name_valid] ,"android").should eql $data[:str][$lang][:apps_signing_key_unlocked]
      @edit_account_page.get_status_of_signing_key($data[:signing_key][:android][:name_invalid] ,"android").should eql $data[:str][$lang][:apps_signing_key_locked]
    end

    it "IT_006: check BlackBerry signing_key in edit_account page" do
      @edit_account_page.get_status_of_signing_key($data[:signing_key][:blackberry][:name_valid] ,"blackberry").should eql $data[:str][$lang][:apps_signing_key_unlocked]
      @edit_account_page.get_status_of_signing_key($data[:signing_key][:blackberry][:name_invalid] ,"blackberry").should eql $data[:str][$lang][:apps_signing_key_locked]
    end

  end

end

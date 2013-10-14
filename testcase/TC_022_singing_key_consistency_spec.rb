#encoding: utf-8

require 'rubygems'
require 'rspec'
require 'selenium-webdriver'
require 'yaml'

require_relative "../action/new_app_page"
require_relative "../action/edit_account_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/new_app_locator"
require_relative "../util/dialog_locator/app_id_locator"

describe "TC_009: signing_key_add_and_unlock_rspec" do
  include ConfigParam
  include WebdriverHelper
  include NewAppLocator
  include AppIdLocator

  before(:all) do
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_022_IT_"
    @base_url = base_url
    #@base_url = "https://buildstage.phonegap.com"
    @driver = driver # have to start a new instance each time to clean the cache.
    @driver.manage.window.maximize
    @driver.manage.timeouts.implicit_wait = 30
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")
    @new_app_page = NewAppPage.new :driver => @driver,
                                   :base_url =>@base_url ,
                                   :user => {:id => $data[:user][$lang][:adobe_id_free_001][:id], :password =>  $data[:user][$lang][:adobe_id_free_001][:password] }
    @edit_account_page = EditAccountPage.new(
        :driver => @driver,
        :base_url => @base_url,
        :user => {:id => $data[:user][$lang][:adobe_id_free_001][:id], :password => $data[:user][$lang][:adobe_id_free_001][:password]} )

  end

  after(:all) do
    webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_001][:id], $data[:user][$lang][:adobe_id_free_001][:password]
    webhelper_delete_all_signing_keys($data[:user][$lang][:adobe_id_free_001][:id], $data[:user][$lang][:adobe_id_free_001][:password])
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

    it "IT_003: the new-added Android signing_key should be locked after adding successfully" do
      @edit_account_page.add_android_signing_key "valid"
      @edit_account_page.get_status_of_1st_android_signing_key.should eql $data[:str][$lang][:apps_signing_key_locked]
    end

    it "IT_004: the new-added BlackBerry signing_key should be locked after adding successfully" do
      @edit_account_page.add_blackberry_signing_key "valid"
      @edit_account_page.get_status_of_1st_blackberry_signing_key.should eql $data[:str][$lang][:apps_signing_key_locked]
    end

  end

  context "--- check signing-key through 'app ' page. " do

    before (:all) do
      @driver.get @base_url + "\/apps"
      @new_app_page.new_app_with_zip; sleep 5
      new_app_locator(:ready_to_build_btn).click; sleep 5
      @driver.navigate.refresh; sleep 5
      @app_id = @new_app_page.first_app_id
      @driver.get @base_url + "\/apps\/#{@app_id}\/builds" ;sleep 5
      @current_url = @driver.current_url
      puts "+<current_url> is #{@current_url}";
    end

    it "IT_005: the unlocked iOS signing Key should be display" do
      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:ios_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:ios_action).text
        end
        break
      }
      builds(:ios_options_firefox).attribute('label').should  eql $data[:str][$lang][:apps_signing_key_unlocked]
      builds(:ios_no_key).text.should eql $data[:signing_key][:ios][:name_valid]
    end

    it "IT_006: the locked Android Key should be display" do
      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:android_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:android_action).text
        end
        break
      }
      builds(:android_options_firefox).attribute('label').should  eql $data[:str][$lang][:apps_signing_key_locked]
      builds(:android_no_key).text.should eql $data[:signing_key][:android][:name_valid]
    end

    it "IT_007: the locked BlackBerry Key should be display" do
      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:blackberry_action).text do
          sleep 5
          puts "+ action: " + builds(:blackberry_action).text
        end
        break
      }
      builds(:blackberry_options_firefox).attribute('label').should  eql $data[:str][$lang][:apps_signing_key_locked]
      builds(:blackberry_no_key).text.should eql $data[:signing_key][:blackberry][:name_valid]
    end

  end

end

#encoding: utf-8

require 'rspec'
require 'rubygems'
require 'selenium-webdriver'
require 'yaml'

require_relative '../action/new_app_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/header_footer_locator'
require_relative '../util/dialog_locator/new_app_locator'
require_relative '../util/dialog_locator/app_id_locator'
require_relative "../util/dialog_locator/edit_account_locator"

# This TC describes
# situations when try to create app(s) using free account(Adobe ID & Github-connected Adobe ID)
describe "TC_025: app id plugins" do

  include ConfigParam
  include WebdriverHelper
  include HeaderFooterLocator
  include NewAppLocator
  include AppIdLocator
  include EditAccountLocator

  before(:all) do
    puts "+ <TC_025> before all outer --- begin"
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_025_IT_"
    @base_url = base_url
    @driver = driver
    @driver.manage.timeouts.implicit_wait = 30
    @driver.manage.window.maximize
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")

    @new_app_page = NewAppPage.new :driver => @driver,
                                   :base_url => @base_url,
                                   :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password => $data[:user][$lang][:adobe_id_free_002][:password]}
    @new_app_page.new_public_app_with_repo ("plugin_repo"); sleep 10
    @app_id_plugin = @new_app_page.first_app_id
    new_app_locator(:ready_to_build_btn).click; sleep 10
    @driver.navigate.refresh ; sleep 5
    puts "+ <TC_025> before all outer --- end"
  end

  # Try to delete all new-created apps
  # to make sure it be a clean run the next time.
  after(:all) do
    puts "+ <TC_025> after all outer --- begin"
    webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
    webhelper_delete_all_signing_keys $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
    @driver.quit
    puts "+ <TC_025> after all outer --- end"
  end

  after(:each) do # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  context "check key of windows phone" do

    it "IT_001: check key of windows phone string on app build page" do
      @driver.get "#{@base_url}\/apps\/#{@app_id_plugin}\/builds" ;sleep 5
      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:winphone_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:winphone_action).text
        end
        break
      }
      if($data[:str][$lang][:builds_action_pending] != builds(:winphone_action).text)
        builds(:winphone_label).text.should eql $data[:str][$lang][:builds_winphone_no_key]
        builds(:winphone_new_key).text.should eql $data[:str][$lang][:builds_winphone_new_key]
        builds(:winphone_pubid_label).attribute('label').should eql $data[:str][$lang][:builds_winphone_pubid_label]
      end
    end

    it "IT_002: check add windows phone key on app build page" do
      browser = ENV['PGBBROWSER'].to_sym
      if browser == :firefox
        builds(:winphone_options_firefox).click; sleep 2
      else
        builds(:winphone_options).click; sleep 2
      end
      builds(:winphone_new_key).click; sleep 2
      builds(:winphone_title_input).send_keys "ddddddddd"
      builds(:winphone_pubid_input).send_keys "ddddddddd"
      builds(:winphone_submit_btn).click; sleep 10
      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:winphone_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:winphone_action).text
        end
        break
      }
      if($data[:str][$lang][:builds_action_pending] != builds(:winphone_action).text)
        builds(:winphone_1st_pubid).text.should eql "ddddddddd"
      end
    end

    it "IT_003: check windows phone key consistency" do
      go_to_page_edit_account
      ea_signing_keys(:signing_keys_tab).click
      ea_signing_keys(:winphone_1st_title_label).text.should eql "ddddddddd"
    end

    it "IT_004: the number of WindowsPhone signing-key should be 0 after deleting the one added above" do
      ea_signing_keys(:winphone_1st_delete_btn).click
      @driver.switch_to.alert.accept;sleep 5
      @driver.navigate.refresh; sleep 5
      ea_signing_keys(:signing_keys_tab).click
      winphone_key_count = @driver.find_element(:xpath => "//*[@id='person-keys']/table[4]/tbody").find_elements(:tag_name => "tr").count
      winphone_key_count.should eql 0
    end

    it "IT_005: the new-added WindowsPhone signing_key should be locked after adding successfully" do
      ea_signing_keys(:winphone_add_key_btn).click
      ea_signing_keys(:winphone_pubid_label).text.should eql $data[:str][$lang][:winphone_pubid_label]
      ea_signing_keys(:winphone_title_input).send_keys "sssss"
      ea_signing_keys(:winphone_pubid_input).send_keys "sssss"
      ea_signing_keys(:winphone_submit_btn).click; sleep 5
      ea_signing_keys(:winphone_1st_title_label).text.should eql "sssss"
    end

    it "IT_006: check windows phone key consistency" do
      @driver.get "#{@base_url}\/apps\/#{@app_id_plugin}\/builds" ;sleep 5
      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:winphone_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:winphone_action).text
        end
        break
      }
      if($data[:str][$lang][:builds_action_pending] != builds(:winphone_action).text)
        builds(:winphone_1st_pubid).text.should eql "sssss"
      end
    end

    it "IT_007: the number of WindowsPhone signing-key should be 0 after deleting the one added above" do
      go_to_page_edit_account
      ea_signing_keys(:signing_keys_tab).click
      ea_signing_keys(:winphone_1st_delete_btn).click
      @driver.switch_to.alert.accept;sleep 5
      @driver.navigate.refresh; sleep 5
      ea_signing_keys(:signing_keys_tab).click
      winphone_key_count = @driver.find_element(:xpath => "//*[@id='person-keys']/table[4]/tbody").find_elements(:tag_name => "tr").count
      winphone_key_count.should eql 0
    end

  end

end

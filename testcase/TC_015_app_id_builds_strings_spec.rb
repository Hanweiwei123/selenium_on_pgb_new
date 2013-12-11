#encoding: utf-8

require 'rubygems'
require 'rspec'
require 'timeout'
require "rautomation"

require_relative "../action/new_app_page"
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
    @name_screenshot = "TC_015_IT_"
    @base_url = base_url
    #@base_url = "https://buildstage.phonegap.com"
    #@base_url = "https://build.phonegap.com"
    @driver = driver
    @driver.manage.timeouts.implicit_wait = 100
    @download_dir = Dir.home + "/Downloads"
    @driver.manage.window.maximize
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")

    @new_app_page = NewAppPage.new :driver => @driver,
                                   :base_url => @base_url,
                                   #:user => { :id => "shuai.yan@dilatoit.com", :password => "yanshuai110" }
                                   :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password => $data[:user][$lang][:adobe_id_free_002][:password]}
    @new_app_page.new_app_with_zip; sleep 15
    @app_id = @new_app_page.first_app_id
    new_app_locator(:ready_to_build_btn).click; sleep 10
    @driver.get "#{@base_url}\/apps\/#{@app_id}\/builds"
    @current_url = @driver.current_url
    puts "+<current_url> is #{@current_url}"; sleep 10
  end

  after(:all) do
    webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
    #webhelper_delete_all_apps "shuai.yan@dilatoit.com", "yanshuai110"
    @driver.quit
  end

  after(:each) do # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  context "Check strings of 'Builds' tab" do

    before(:each) do
      builds(:tab).click; sleep 5
    end

    it "IT_001: brief info checking" do
      builds(:app_id_label).text.should eql $data[:str][$lang][:builds_app_id_label]
      builds(:version_label).text.should eql $data[:str][$lang][:builds_version_label]
      #hide for sometimes :phonegap_label 'Last built' has '(num)'
      #builds(:phonegap_label).text.should eql $data[:str][$lang][:builds_phonegap_label]
      builds(:owner_label).text.should eql $data[:str][$lang][:builds_owner_label]
      builds(:last_built_label).text.should include($data[:str][$lang][:builds_last_built_label])
      builds(:source_label).text.should eql $data[:str][$lang][:builds_source_label]
      puts "+ <result> IT_001:PASS"
    end

    it "IT_002: should match to localized strings: >> iOS <<" do

      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:ios_action).text do
          @driver.navigate.refresh; sleep 10
          puts "+ action: " + builds(:ios_action).text
        end
        break
      }
      text=builds(:ios_action).text
      puts "+ iOS action: " + text
      if (text ==$data[:str][$lang][:builds_action_error])
        builds(:ios_action).click
        if is_element_present(:app_builds_page, :ios_msg)
          builds(:ios_msg).text.should eql $data[:str][$lang][:error_msg_ios_build_without_signing_key]
        else
          puts "+<error> the error message should be display."
        end
        builds(:ios_action).click
      end
      builds(:ios_rebuild).text.should eql $data[:str][$lang][:builds_rebuild]
      builds(:ios_label).text.should eql $data[:str][$lang][:builds_label]
      builds(:ios_options_firefox).attribute('label').should eql $data[:str][$lang][:builds_options]
      builds(:ios_no_key).text.should eql $data[:str][$lang][:builds_no_key]
      builds(:ios_new_key).text.should eql $data[:str][$lang][:builds_new_key]
      puts "+ <result> IT_002:PASS"

    end

    it "IT_003: should match to localized strings: >> Android <<" do

      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:android_action).text do
          @driver.navigate.refresh; sleep 10
          puts "+ action: " + builds(:android_action).text
        end
        break
      }
      builds(:android_rebuild).text.should eql $data[:str][$lang][:builds_rebuild]
      builds(:android_label).text.should eql $data[:str][$lang][:builds_label]
      builds(:android_options_firefox).attribute('label').should eql $data[:str][$lang][:builds_options]
      builds(:android_no_key).text.should eql $data[:str][$lang][:builds_no_key]
      builds(:android_new_key).text.should eql $data[:str][$lang][:builds_new_key]
      puts "+ <result> IT_003:PASS"

    end

    it "IT_004: should match to localized strings: >> WinPhone <<" do

      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:winphone_action).text do
          @driver.navigate.refresh; sleep 10
          puts "+ action: " + builds(:winphone_action).text
        end
        break
      }
      builds(:winphone_rebuild).text.should eql $data[:str][$lang][:builds_rebuild]
      puts "+ <result> IT_004:PASS"

    end

    it "IT_005: should match to localized strings: >> BlackBerry <<" do

      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:blackberry_action).text do
          @driver.navigate.refresh; sleep 10
          puts "+ action: " + builds(:blackberry_action).text
        end
        break
      }
      builds(:blackberry_rebuild).text.should eql $data[:str][$lang][:builds_rebuild]
      builds(:blackberry_label).text.should eql $data[:str][$lang][:builds_label]
      builds(:blackberry_options_firefox).attribute('label').should eql $data[:str][$lang][:builds_options]
      builds(:blackberry_no_key).text.should eql $data[:str][$lang][:builds_no_key]
      builds(:blackberry_new_key).text.should eql $data[:str][$lang][:builds_new_key]
      puts "+ <result> IT_005:PASS"

    end

    it "IT_006: should match to localized strings: >> WebOS <<" do

      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:webos_action).text do
          @driver.navigate.refresh; sleep 10
          puts "+ action: " + builds(:webos_action).text
        end
        break
      }
      builds(:webos_rebuild).text.should eql $data[:str][$lang][:builds_rebuild]
      puts "+ <result> IT_006:PASS"

    end

    it "IT_007: should match to localized strings: >> Symbian <<" do

      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:symbian_action).text do
          @driver.navigate.refresh; sleep 10
          puts "+ action: " + builds(:symbian_action).text
        end
        break
      }
      builds(:symbian_rebuild).text.should eql $data[:str][$lang][:builds_rebuild]
      puts "+ <result> IT_007:PASS"

    end

  end

  context "Apps without signing-key downloading" do

    it "IT_008: the >>winphone<< app should be downloaded successfully" do

      if $data[:str][$lang][:builds_action_pending] != builds(:winphone_action).text
        builds(:winphone_action).click; sleep 10
        download_with_different_browser
        sleep 10
        Dir["#{@download_dir}/*.xap"].count.should > 0
        system("rm #{@download_dir}/*.xap")
      else
        puts "+ <result> winphone app was not available"
      end

    end

    it "IT_009: the >>webos<< app should be downloaded successfully" do
      if $data[:str][$lang][:builds_action_pending] != builds(:webos_action).text
        if :chrome == ENV['PGBBROWSER'].to_sym
          @driver.get @base_url + "\/apps\/"; sleep 5
          @driver.get @base_url + "\/apps\/#{@app_id}\/builds"; sleep 5
        end
        builds(:webos_action).click; sleep 10
        download_with_different_browser
        sleep 10
        Dir["#{@download_dir}/*.ipk*"].count.should > 0
        system("rm #{@download_dir}/*.ipk*")
      else
        puts "+ <result> webos app was not available"
      end

    end

    it "IT_010: the >>symbian<< app should be downloaded successfully" do

      if $data[:str][$lang][:builds_action_pending] != builds(:symbian_action).text
        if :chrome == ENV['PGBBROWSER'].to_sym
          @driver.get @base_url + "\/apps\/"; sleep 5
          @driver.get @base_url + "\/apps\/#{@app_id}\/builds"; sleep 5
        end
        builds(:symbian_action).click; sleep 10
        download_with_different_browser
        sleep 10
        Dir["#{@download_dir}/*.wgz"].count.should > 0
        system("rm #{@download_dir}/*.wgz")
      else
        puts "+ <result> symbian app was not available"
      end

    end

  end

end

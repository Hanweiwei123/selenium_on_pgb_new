#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative '../action/sign_in_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/plugins_locator'
require_relative '../util/dialog_locator/header_footer_locator'

# This TC describes:
describe "TC_027: check string of error plugins" do

  include ConfigParam
  include WebdriverHelper
  include PluginsLocator
  include HeaderFooterLocator

  before(:all) do
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_027_IT_"
    @base_url = base_url # "https://buildstage.phonegap.com"
    @driver =driver
    @driver.manage.window.maximize
    @driver.manage.timeouts.implicit_wait = 30
  end

  after(:each) do # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  after(:all) do
    @driver.quit
  end

  context "Trying to submit plugin with Adobe ID" do
    before(:all) do
      @sign_in_page = SignInPage.new(
          :driver => @driver,
          :base_url => @base_url,
          :user => {:id => $data[:user][$lang][:adobe_id_free_001][:id],
                    :password => $data[:user][$lang][:adobe_id_free_001][:password]})
      @sign_in_page.sign_in_with_adobe_id
      sleep 5
      @driver.current_url.should == @base_url + $data[:url][:sign_in_successfully]
      header(:main_nav_link_plugins).click
      plugin_locator(:tab_submit_plugin).click
    end

    after(:all) do
      sign_out
    end

    it "IT_001: check invaild version string Localized" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:invaild_version][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 5
      plugin_locator(:header_notifications).text.should eql $data[:str][$lang][:plugin_invaild_version_error]
    end

    it "IT_002: check no version string Localized" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:no_version][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 5
      plugin_locator(:header_notifications).text.should eql $data[:str][$lang][:plugin_no_version_error]
    end

    it "IT_003: check invaild attribute string Localized" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:invaild_attribute][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 5
      plugin_locator(:header_notifications).text.should eql $data[:str][$lang][:plugin_invaild_attribute_error]
    end

    it "IT_004: check no plugin string Localized" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:no_plugin][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 5
      plugin_locator(:header_notifications).text.should eql $data[:str][$lang][:plugin_no_plugin_error]
    end

    it "IT_005: check no platform string Localized" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:no_platform][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 5
      plugin_locator(:header_notifications).text.should eql $data[:str][$lang][:plugin_no_platform_error]
    end

    it "IT_006: check no id string Localized" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:no_id][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 5
      plugin_locator(:header_notifications).text.should eql $data[:str][$lang][:plugin_no_id_error]
    end

    it "IT_007: check no description string Localized" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:no_description][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 5
      plugin_locator(:header_notifications).text.should eql $data[:str][$lang][:plugin_no_description_error]
    end

    it "IT_008: check string Localized malformed plugin.xml only has string ttt" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:malformed][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 5
      plugin_locator(:header_notifications).text.should eql $data[:str][$lang][:plugin_malformed_error]
    end

    it "IT_009: check no name string Localized" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:no_name][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 5
      plugin_locator(:header_notifications).text.should eql $data[:str][$lang][:plugin_no_name_error]
    end
    
     it "IT_010: check Compiled binaries are not allowed in user submitted Plugins string Localized" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:compiled_binaries][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 10
      plugin_locator(:header_notifications).text.should include $data[:str][$lang][:plugin_compiled_binaries_error]
    end
  end

  context "Trying to submit plugin with free Adobe ID connected Github" do
    before(:all) do
      @sign_in_page = SignInPage.new(
          :driver => @driver,
          :base_url => @base_url,
          :user => {:id => $data[:user][$lang][:adobe_id_free_connected_github][:id],
                    :password => $data[:user][$lang][:adobe_id_free_connected_github][:password]})
      @sign_in_page.sign_in_with_adobe_id
      sleep 5
      @driver.current_url.should == @base_url + $data[:url][:sign_in_successfully]
      header(:main_nav_link_plugins).click
      plugin_locator(:tab_submit_plugin).click
    end

    after(:all) do
      sign_out
    end

    it "IT_011: check no name string Localized" do
      plugin_locator(:plugin_git_repository_url).attribute('placeholder').to_s.should eql $data[:str][$lang][:PGB_find_existing_repo_or_paste_git_repo]
    end

    it "IT_012: check no name string Localized" do
      li_count = @driver.find_elements(:xpath => "//div[input[@id='plugin_git_url']]/ul/li").count
      puts "+li count: #{li_count}"
      li_count.should_not eql 0
    end

  end

end

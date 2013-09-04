#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative '../action/sign_in_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/plugins_locator'
require_relative '../util/dialog_locator/header_footer_locator'

# This TC describes:
#   situations:
#       Sign in with Adobe ID
#       Sign in with Github ID
#       Forgot password
#       Didn't receive confirmation
describe "TC_010: plugins_before_sign_in" do
  include PluginsLocator
  include ConfigParam
  include WebdriverHelper
  include HeaderFooterLocator

  before(:all) do
    #mixin init function in ConfigParam
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_010_IT_"
    @base_url = base_url
    @driver =driver
    @driver.manage.window.maximize
    @driver.get path_format_locale("",@base_url)
    header_get(:main_nav_link_plugins).click
  end

  after(:each) do  # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  after(:all) do
    @driver.quit
  end

     it "IT_001: should match to the localized 'Plugins' " do
  #        plugin_dialog_get(:title).text.should eql @data_str[$lang][:plugin_title]
           @plugin_title = plugin_locator(:title).text
           @plugin_title.should eql $data[:str][$lang][:plugin_title]
     end
  #
     it "IT_003: should match to the localized 'All Supported Plugins' " do
  #        plugin_dialog_get(:tab_all_supported_plugins).text.should eql @data_str[$lang][:plugin_tab_all_supported_plugins]
           @tab_all_supported_plugins = plugin_locator(:tab_all_supported_plugins).text
           @tab_all_supported_plugins.should eql $data[:str][$lang][:plugin_tab_all_supported_plugins]
      end
  #
     it "IT_004: should match to the localized 'Your Plugins' " do
  #        plugin_dialog_get(:tab_your_plugins).text.should eql @data_str[$lang][:plugin_tab_your_plugins]
           @tab_your_plugins = plugin_locator(:tab_your_plugins).text
           @tab_your_plugins.should eql $data[:str][$lang][:plugin_tab_your_plugins]
      end
  #
      it "IT_005: should match to the localized 'Submit Plugin' " do
  #        plugin_dialog_get(:tab_submit_plugin).text.should eql @data_str[$lang][:plugin_tab_submit_plugin]
           @tab_submit_plugin = plugin_locator(:tab_submit_plugin).text
           @tab_submit_plugin.should eql $data[:str][$lang][:plugin_tab_submit_plugin]
      end
  #
      it "IT_006: should match to the localized 'Please sign in to submit or view your plugins.' at 'Your Plugins' tab " do
  #        plugin_dialog_get(:tab_your_plugins).click
  #        plugin_dialog_get(:please_sign_in_your).text.should eql @data_str[$lang][:plugin_please_sign_in_your]
           plugin_locator(:tab_your_plugins).click
           @please_sign_in_your = plugin_locator(:please_sign_in_your).text
           @please_sign_in_your.should eql $data[:str][$lang][:plugin_please_sign_in_your]
      end
  #
      it "IT_007: should match to correct url '/people/sign_in'" do
  #        plugin_dialog_get(:link_sign_in_tab_your_plugins).attribute('href').should eql "#{base_url}/people/sign_in"
           plugin_locator(:link_sign_in_tab_your_plugins).attribute('href').should eql "#{base_url}/people/sign_in"
      end
  #
      it "IT_008: should match to the localized 'Please sign in to submit or view your plugins.' at 'Submit Plugin' tab " do
  #        plugin_dialog_get(:tab_submit_plugin).click
  #        plugin_dialog_get(:please_sign_in_add).text.should eql @data_str[$lang][:plugin_please_sign_in_add]
        plugin_locator(:tab_submit_plugin).click
        @please_sign_in_add = plugin_locator(:please_sign_in_add).text
        @please_sign_in_add.should eql $data[:str][$lang][:plugin_please_sign_in_add]
      end
  #
      it "IT_009: should match to correct url '/people/sign_in'" do
  #        plugin_dialog_get(:link_sign_in_tab_submit_plugin).attribute('href').should eql "#{base_url}/people/sign_in"
           plugin_locator(:link_sign_in_tab_submit_plugin).attribute('href').should eql "#{base_url}/people/sign_in"
      end

end

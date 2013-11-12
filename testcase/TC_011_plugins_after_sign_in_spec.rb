#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative '../action/sign_in_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/sign_in_locator'
require_relative '../util/dialog_locator/plugins_locator'
require_relative '../util/dialog_locator/header_footer_locator'

# This TC describes:
describe "TC_011: Plugins" do
  include SignInLocator
  include PluginsLocator
  include ConfigParam
  include WebdriverHelper
  include HeaderFooterLocator

  before(:all) do
    #mixin init function in ConfigParam
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_011_IT_"
    @base_url = base_url # "https://buildstage.phonegap.com"
    @driver =driver
    @driver.manage.window.maximize
    @driver.manage.timeouts.implicit_wait = 30
    @sign_in_page = SignInPage.new(
        :driver => @driver,
        :base_url => @base_url,
        :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id],
                  :password => $data[:user][$lang][:adobe_id_free_002][:password]})
    @sign_in_page.sign_in_with_adobe_id
    sleep 5
    @driver.current_url.should == @base_url + $data[:url][:sign_in_successfully]
    header_get(:main_nav_link_plugins).click
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

  it "IT_001: should have no submitted plugins" do
    plugin_locator(:tab_your_plugins).click
    @tab_your_plugins = plugin_locator(:you_have_no_plugins).text
    @tab_your_plugins.should eql $data[:str][$lang][:plugin_you_have_no_plugins]
  end

  describe "Trying to submit plugin with Adobe ID" do
    before(:all) do
      plugin_locator(:tab_submit_plugin).click
    end

    it "IT_002: should match to localized error msg when filling in repo url with invalid one" do
      plugin_locator(:plugin_max_repo_size_label).text.should eql $data[:str][$lang][:plugin_max_repo_size_label]
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:invalid_plugin][:url])
      plugin_locator(:optional_tag_or_branch).attribute("placeholder").should eql "master"
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click
      sleep 10
      @plugin_git_repository_url_msg = plugin_locator(:header_notifications).text
      @plugin_git_repository_url_msg.should eql $data[:str][$lang][:plugin_uri_invalid_msg]
    end

    it "IT_003: should submit plugin successfully" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:new_plugin][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 20
      @driver.current_url.should =~ /\/plugins\/\d+/
      @plugin_submit_successfully_msg = plugin_locator(:header_notifications).text
      @plugin_submit_successfully_msg.should eql $data[:str][$lang][:plugin_submit_successfully_msg]
    end


    it "IT_004: should match to localized msg 'duplicated'" do
      #  @driver.get path_format_locale("/plugins","")
      # @driver.get "@base_url.to_s + /plugins"
      header_get(:main_nav_link_plugins).click
      plugin_locator(:tab_submit_plugin).click
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:new_plugin][:url])
      plugin_locator(:optional_tag_or_branch).send_keys($data[:plugin][:new_plugin][:branch])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 10
      @driver.current_url.should eql @base_url+"\/plugins#add"
      @plugin_submit_duplicated_msg = plugin_locator(:header_notifications).text
      @plugin_submit_duplicated_msg.should eql $data[:str][$lang][:plugin_submit_duplicated_msg]
    end

  end

end


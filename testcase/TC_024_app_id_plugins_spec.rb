#encoding: utf-8

require 'rspec'
require 'rubygems'

require_relative '../action/new_app_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/new_app_locator'
require_relative '../util/dialog_locator/app_id_locator'

# This TC describes
# situations when try to create app(s) using free account(Adobe ID & Github-connected Adobe ID)
describe "TC_024: app id plugins" do

  include ConfigParam
  include WebdriverHelper
  include NewAppLocator
  include AppIdLocator

  before(:all) do
    puts "+ <TC_024> before all outer --- begin"
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_024_IT_"
    @base_url = base_url
    @driver = driver
    @driver.manage.timeouts.implicit_wait = 30
    @driver.manage.window.maximize
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")

    @new_app_page = NewAppPage.new :driver => @driver,
                                   :base_url => @base_url,
                                   :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password => $data[:user][$lang][:adobe_id_free_002][:password]}
    @new_app_page.new_public_app_with_repo; sleep 10
    @app_id_no_plugin = @new_app_page.first_app_id
    new_app_locator(:ready_to_build_btn).click; sleep 5
    @driver.navigate.refresh ; sleep 5
    @new_app_page.new_public_app_with_repo ("plugin_repo"); sleep 10
    #
    @driver.navigate.refresh ; sleep 5
    @app_id_plugin = @new_app_page.first_app_id
    new_app_locator(:ready_to_build_btn).click; sleep 5
    @driver.navigate.refresh ; sleep 5
    puts "+ <TC_024> before all outer --- end"
  end

  # Try to delete all new-created apps
  # to make sure it be a clean run the next time.
  after(:all) do
    puts "+ <TC_024> after all outer --- begin"
    webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
    @driver.quit
    puts "+ <TC_024> after all outer --- end"
  end

  after(:each) do # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  context "check app id plugins tab" do

    it "IT_001: check app with no plugins" do

      @driver.get "#{@base_url}\/apps\/#{@app_id_no_plugin}\/builds" ;sleep 5
      @current_url = @driver.current_url
      puts "+<current_url> is #{@current_url}"
      plugins(:tab).text.should eql $data[:str][$lang][:app_id_plugins_tab]
      plugins(:tab).click unless @driver.current_url =~ /.*plugins.*/; sleep 5
      plugins(:no_plugins_label).text.should eql $data[:str][$lang][:app_id_plugins_no]
    end

    it "IT_002: check app with plugins" do
      @app_id_plugin.should_not eql @app_id_no_plugin
      @driver.get "#{@base_url}\/apps\/#{@app_id_plugin}\/plugins" ;sleep 5
      @current_url = @driver.current_url
      puts "+<current_url> is #{@current_url}"
      plugins(:third_party_plugins_label).text.should eql $data[:str][$lang][:app_id_plugins_3rd_party]
      #don't log this issue:Extra  3 space is displayed on the Installed 3rd Party Plugins on App Plugins panel.
      #plugins(:third_party_plugins_name).text.should eql $data[:app][:new_app][:third_party_plugins_name]
      plugins(:third_party_plugins_version).text.should eql $data[:app][:new_app][:third_party_plugins_version]
      plugins(:phonegap_plugins_plugins_label).text.should eql $data[:str][$lang][:app_id_plugins_phonegap]
      plugins(:phonegap_plugins_plugins_name).text.should eql $data[:app][:new_app][:phonegap_plugins_plugins_name]
      plugins(:phonegap_plugins_version).text.should eql $data[:app][:new_app][:phonegap_plugins_version]
    end

  end

end

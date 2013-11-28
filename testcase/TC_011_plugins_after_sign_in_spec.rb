#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative '../action/sign_in_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/plugins_locator'
require_relative '../util/dialog_locator/header_footer_locator'
require_relative '../util/dialog_locator/app_id_locator'

# This TC describes:
describe "TC_011: Plugins" do

  include ConfigParam
  include WebdriverHelper
  include HeaderFooterLocator
  include PluginsLocator
  include AppIdLocator

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
    header(:main_nav_link_plugins).click
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

    it "IT_001: should have no submitted plugins" do
      plugin_locator(:tab_your_plugins).click
      @tab_your_plugins = plugin_locator(:you_have_no_plugins).text
      @tab_your_plugins.should eql $data[:str][$lang][:plugin_you_have_no_plugins]
    end

    it "IT_002: should match to localized error msg when filling in repo url with invalid one" do
      plugin_locator(:tab_submit_plugin).click
      plugin_locator(:plugin_max_repo_size_label).text.should eql $data[:str][$lang][:plugin_max_repo_size_label]
      plugin_locator(:plugin_git_repository_url).send_keys("xxxxx")
      plugin_locator(:optional_tag_or_branch).attribute("placeholder").should eql "master"
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:btn_terms_cancle_plugin).click
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click
      sleep 5
      @plugin_git_repository_url_msg = plugin_locator(:header_notifications).text
      @plugin_git_repository_url_msg.should eql $data[:str][$lang][:plugin_uri_invalid_msg]
    end

    it "IT_003: should submit plugin successfully" do
      plugin_locator(:plugin_git_repository_url).clear
      plugin_locator(:plugin_git_repository_url).send_keys($data[:plugin][:new_plugin][:url])
      plugin_locator(:btn_submit_plugin).click
      plugin_locator(:checkbox_accept_license).click
      plugin_locator(:btn_submit).click # will submit the plugin
      sleep 10
      @driver.current_url.should =~ /\/plugins\/\d+/
      @plugin_submit_successfully_msg = plugin_locator(:header_notifications).text
      @plugin_submit_successfully_msg.should eql $data[:str][$lang][:plugin_submit_successfully_msg]
    end

    it "IT_004: check report abuse localized strings" do
      puts "+<check> report_abuse_form style is " + abuse(:report_abuse_form).attribute("style")
      abuse(:report_abuse_form).attribute("style").should include "display: none"
      plugin_locator(:plugin_id_abuse_btn).text.should eql $data[:str][$lang][:app_id_abuse_report_title]
      plugin_locator(:plugin_id_abuse_btn).click
      abuse(:report_abuse_title).text.should eql $data[:str][$lang][:app_id_abuse_report_title]
      abuse(:email_address_label).text.should eql   $data[:str][$lang][:app_id_abuse_email_label]
      abuse(:email_address_input).attribute("value").should eql $data[:user][$lang][:adobe_id_free_002][:id]
      #abuse(:name_label).text.should eql   $data[:str][$lang][:app_id_abuse_name_label]
      abuse(:why_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_label]
      abuse(:why_Defamation_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_Defamation_label]
      abuse(:why_SEC_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_SEC_label]
      abuse(:why_TI_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_TI_label]
      abuse(:why_OC_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_OC_label]
      abuse(:why_RHC_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_RHC_label]
      abuse(:why_Other_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_Other_label]
      abuse(:description_label).text.should eql   $data[:str][$lang][:app_id_abuse_description_label]
      abuse(:copyright_violation_label).text.should eql   $data[:str][$lang][:app_id_abuse_copyright_violation_label]
      abuse(:copyright_violation_link).attribute("href").should include "/misc/terms.html"
    end

    it "IT_005: should cancel report abuse successfully" do
      abuse(:cancel_btn).click;
      puts "+<check> report_abuse_form style is " + abuse(:report_abuse_form).attribute("style")
      abuse(:report_abuse_form).attribute("style").should include "display: none"
    end

    it "IT_006: should submit report abuse successfully" do
      plugin_locator(:plugin_id_abuse_btn).click
      abuse(:email_address_input).clear
      abuse(:email_address_input).send_keys($data[:user][$lang][:adobe_id_free_002][:id])
      abuse(:name_input).clear
      abuse(:name_input).send_keys "name"
      abuse(:why_Defamation_input).click;
      abuse(:why_SEC_input).click;
      abuse(:why_TI_input).click;
      abuse(:why_OC_input).click;
      abuse(:why_RHC_input).click;
      abuse(:why_Other_input).click;
      abuse(:why_Defamation_input).click;
      abuse(:description_input).clear
      abuse(:description_input).send_keys "description"
      abuse(:report_btn).click; sleep 5
      abuse(:report_success_label).text.should eql $data[:str][$lang][:app_id_abuse_report_success_title]
    end

    it "IT_007: should match to localized msg 'duplicated'" do
      header(:main_nav_link_plugins).click
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

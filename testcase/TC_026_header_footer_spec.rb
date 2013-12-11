#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative '../action/sign_in_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/header_footer_locator'

# This TC describes:
describe "TC_026: Sign in" do
  include ConfigParam
  include WebdriverHelper
  include HeaderFooterLocator

  before(:all) do
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_026_IT_"
    @base_url = base_url
    @driver =driver
    @driver.manage.window.maximize
    @driver.manage.timeouts.implicit_wait = 30
    @sign_in_page = SignInPage.new(
        :driver => @driver,
        :base_url => @base_url,
        :user => {:id => $data[:user][$lang][:adobe_id_free_001][:id], :password => $data[:user][$lang][:adobe_id_free_001][:password]} )
  end

  after(:each) do  # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    begin
      if example.exception != nil
        take_screenshot_with_name @name_screenshot
      end
    end
  end

  after(:all) do
    @driver.quit
  end


  context "check header link string and href before sign in" do
    it "IT_001: check string" do
      @driver.get @base_url+ "?locale=" + $lang.to_s
      header(:main_nav_link_apps).text.should eql $data[:str][$lang][:home_title]
      footer(:nav_apps).text.should eql $data[:str][$lang][:home_title]
    end
  end

  context "check header link string and href after sign in" do

    before(:all) do
      @sign_in_page.sign_in_with_adobe_id ; sleep 5
    end

    it "IT_002: check string" do
      header(:main_nav_link_apps).text.should eql $data[:str][$lang][:apps_title]
      header(:main_nav_link_plugins).text.should eql $data[:str][$lang][:plugins_title]
      header(:main_nav_link_docs).text.should eql $data[:str][$lang][:Docs_title]
      header(:main_nav_link_blog).text.should eql $data[:str][$lang][:Blog_title]
      header(:main_nav_link_faq).text.should eql $data[:str][$lang][:FAQ_title]
      header(:main_nav_link_support).text.should eql $data[:str][$lang][:support_title]
    end

    it "IT_003: check link" do
      header(:main_nav_link_apps).click
      @driver.current_url.should eql @base_url+$data[:url][:apps]
      go_to_apps_home_page
      header(:main_nav_link_plugins).click
      @driver.current_url.should eql @base_url+$data[:url][:plugins]
      go_to_apps_home_page
      header(:main_nav_link_docs).attribute("href").should eql $data[:url][:docs]+"("+$lang.to_s[0,2]+")"
      go_to_apps_home_page
      header(:main_nav_link_blog).attribute("href").should eql $data[:url][:blog]
      header(:main_nav_link_faq).click
      @driver.current_url.should eql @base_url+$data[:url][:FAQ]
      go_to_apps_home_page
      header(:main_nav_link_support).attribute("href").should eql $data[:url][:support]+"("+$lang.to_s[0,2]+")"
    end
  end

  context "check footer link string and href after sign in" do
    it "IT_004: check string" do
      #unloc string bug
      #footer(:nav_language).text.should eql $data[:str][$lang][:language_title]
      footer(:navigation).text.should eql $data[:str][$lang][:navigation_title]
      footer(:nav_apps).text.should eql $data[:str][$lang][:apps_title]
      footer(:nav_plugins).text.should eql $data[:str][$lang][:plugins_title]
      footer(:nav_docs).text.should eql $data[:str][$lang][:Docs_title]
      footer(:nav_blog).text.should eql $data[:str][$lang][:Blog_title]
      footer(:nav_help).text.should eql $data[:str][$lang][:help_title]
      footer(:nav_account).text.should include $data[:str][$lang][:account_title]
      footer(:nav_sign_out).text.should eql $data[:str][$lang][:sign_out_title]
    end

    it "IT_005: check link" do
      footer(:nav_apps).click
      @driver.current_url.should eql @base_url+$data[:url][:apps]
      go_to_apps_home_page
      footer(:nav_plugins).click
      @driver.current_url.should eql @base_url+$data[:url][:plugins]
      go_to_apps_home_page
      footer(:nav_docs).attribute("href").should eql $data[:url][:docs]+"("+$lang.to_s[0,2]+")"
      go_to_apps_home_page
      footer(:nav_blog).attribute("href").should eql $data[:url][:blog]
      footer(:nav_help).attribute("href").should eql $data[:url][:help]
    end
  end

end

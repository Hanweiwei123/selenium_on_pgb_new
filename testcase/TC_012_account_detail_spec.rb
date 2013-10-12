#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative "../action/edit_account_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/edit_account_locator"

describe "TC_012: 'Account details' page" do
  include ConfigParam
  include WebdriverHelper
  include EditAccountLocator

  before(:all) do 
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_012_IT_"
    @base_url = "https://buildstage.phonegap.com"
    @driver = driver
    @driver.manage.window.maximize
    @driver.manage.timeouts.implicit_wait = 30
    @edit_account_page = EditAccountPage.new(
        :driver => @driver,
        :base_url => @base_url,
        :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password => $data[:user][$lang][:adobe_id_free_002][:password]} )
  end

  after(:all) do 
    @driver.quit
  end

  before(:each) do
    @edit_account_page.make_sure_account_details_tab
  end

  after(:each) do  # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  context "Link/Unlink Github account" do

    it "IT_001: should link to 'http://www.adobe.com/account.html' page" do

      ea_account_details(:manage_your_adobe_id_link).attribute('href').should eql "http://www.adobe.com/account.html"
    end

    it "IT_002: should link Github account successfully" do 
      
      ea_account_details(:connect_a_github_id_btn).click; sleep 10
      @edit_account_page.enter_github_account_and_sign_in_with( $data[:user][$lang][:adobe_id_free_002][:id],  $data[:user][$lang][:adobe_id_free_002][:password] )
      sleep 5
      @driver.current_url.should =~ /https:\/\/buildstage.phonegap.com\/people\/edit/
      ea_account_details(:notification).text.should eql $data[:str][$lang][:edit_account_connect_github_account_successfully]
    end

    it "IT_003: should link to 'https://github.com/settings/applications' page" do 

      ea_account_details(:manage_your_github_account_link).attribute('href').should eql "https://github.com/settings/applications"
    end

    it "IT_004: should unlink the Github account successfully" do 

      ea_account_details(:unlink_github_id_btn).click
      @driver.switch_to.alert.accept
      sleep 10
      ea_account_details(:connect_a_github_id_btn).text.should eql $data[:str][$lang][:edit_account_connect_a_github_id]
    end
  end

  # Token-feature: done! 
  context "Authentication Tokens" do  # create/reset/delete token

    it "IT_005: should be 'no token' at first" do 

      sleep 3
      @current_token = ea_account_details(:token_text).attribute('value')
      @current_token.should eql $data[:str][$lang][:ad_no_token]
    end

    it "IT_006: should be a different token after creating one" do 

      ea_account_details(:token_create_reset_btn).click
      sleep 3
      @current_token = ea_account_details(:token_text).attribute('value')
      @current_token.should_not eql $data[:str][$lang][:ad_no_token]
    end

    it "IT_007: should be a different from the last one after reseting" do 

      token_before = @current_token
      ea_account_details(:token_create_reset_btn).click
      sleep 3
      @current_token = ea_account_details(:token_text).attribute('value')
      @current_token.should_not eql token_before
    end

    it "IT_008: should be 'no token' after deleting it" do 

      ea_account_details(:token_delete_btn).click
      sleep 3
      @current_token = ea_account_details(:token_text).attribute('value')
      @current_token.should eql $data[:str][$lang][:ad_no_token]
    end
  end

end

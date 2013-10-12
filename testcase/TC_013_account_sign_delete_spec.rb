#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative "../action/sign_in_page"
require_relative "../action/edit_account_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/header_footer_locator"
require_relative "../util/dialog_locator/register_locator"

describe "TC_013: User sign in/out and account delete" do
  include ConfigParam
  include WebdriverHelper
  include HeaderFooterLocator
  include EditAccountLocator
  include SignInLocator
  include RegisterLocator

  before(:all) do 
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_013_IT_"
    @base_url = base_url
    @driver = driver
    @driver.manage.window.maximize
    @driver.manage.timeouts.implicit_wait = 30
    @sign_in_page = SignInPage.new(
        :driver => @driver,
        :base_url => @base_url,
        :user => {:id => $data[:user][$lang][:adobe_id_free_001][:id], :password => $data[:user][$lang][:adobe_id_free_001][:password]} )
  end

  after(:all) do 
    @driver.quit
  end

  after(:each) do  # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  # User sign in/out: done! 
  context "User sign in/out" do

    it "IT_001: should sign-in successfully" do

      @sign_in_page.sign_in_with_adobe_id
      @driver.current_url.should =~ /http:\/\/loc.build.phonegap.com\/apps/
      sign_out
    end

    it "IT_002: should sign out successfully" do 
      
      @driver.current_url.should =~ /http:\/\/loc.build.phonegap.com\//
      account_notice.text.should eql $data[:str][$lang][:user_signout_notice]
    end
  end

  context "Danger Zone" do  # Delete my account


    after(:all) do  # recover the deleted account
      go_to_page :free_plan
      register_locator(:adobe_id_btn).click
      @driver.switch_to.frame(0)
      fill_in register_locator(:adobe_id_frame_adobe_id_input),:with => $data[:user][$lang][:adobe_id_free_001][:id]
      fill_in register_locator(:adobe_id_frame_password_input),:with => $data[:user][$lang][:adobe_id_free_001][:password]
      register_locator(:adobe_id_frame_sign_in_btn).click
      sleep 10
    end

    # Delete-account: done!
    it "IT_003: should match to localized 'account-delete-notice'" do
      @edit_account_page = EditAccountPage.new(
          :driver => @driver,
          :base_url => @base_url,
          :user => {:id => $data[:user][$lang][:adobe_id_free_001][:id], :password => $data[:user][$lang][:adobe_id_free_001][:password]} )
      @edit_account_page.make_sure_account_details_tab
      @edit_account_page.delete_my_account( $data[:user][$lang][:adobe_id_free_001][:id],  $data[:user][$lang][:adobe_id_free_001][:password])
      @driver.current_url.should =~ /http:\/\/loc.build.phonegap.com\//
      account_notice.text.should eql $data[:str][$lang][:account_deleted_notice]
    end
  end

end

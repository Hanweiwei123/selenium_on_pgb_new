#encoding: utf-8

require 'rubygems'
require 'rspec'
require 'yaml'
require 'selenium-webdriver'

require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../action/edit_account_page"
require_relative "../util/dialog_locator/edit_account_locator"

describe "TC_014: Edit 'private code hosting' at Edit account page" do
  include ConfigParam
  include WebdriverHelper
  include EditAccountLocator

  before(:all) do 
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_014_IT_"
    @base_url = base_url
    @driver = driver
    @driver.manage.window.maximize
    @driver.manage.timeouts.implicit_wait = 30
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")
    @edit_account_page = EditAccountPage.new(
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

  describe "Private code hosting" do 

    it "IT_001: should change the username and ssh_key successfully" do

      @edit_account_page.make_sure_private_codehosting_tab

      user_name = $data[:user][$lang][:private_code_hosting][:user_name]
      user_ssh_key = $data[:user][$lang][:private_code_hosting][:user_ssh_key]

      ea_private_ch(:person_username_text).clear
      ea_private_ch(:person_username_text).send_keys(user_name)
      ea_private_ch(:person_ssh_key_text).clear
      ea_private_ch(:person_ssh_key_text).send_keys(user_ssh_key)
      ea_private_ch(:save_btn).click
      sleep 5
      @driver.navigate.refresh ; sleep 5
      @driver.current_url.should eql @base_url+ $data[:url][:sign_in_successfully]

      @edit_account_page.make_sure_private_codehosting_tab
      
      ea_private_ch(:person_username_text).attribute('value').should eql user_name
      ea_private_ch(:person_ssh_key_text).text.should eql user_ssh_key
    end
  end

end

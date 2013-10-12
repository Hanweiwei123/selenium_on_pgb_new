#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative '../action/register_page'
require_relative '../util/dialog_locator/register_locator'
require_relative '../util/dialog_locator/header_footer_locator'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'

describe "TC_003: Register -> create an Adobe ID with provided email" do 
    include RegisterLocator
    include ConfigParam
    include WebdriverHelper
    include HeaderFooterLocator

    before(:all) do
        init
        @order_of_it = WebdriverHelper::Counter.new
        @name_screenshot = "TC_003_IT_"
        @base_url = base_url
        @driver = driver
        @driver.manage.timeouts.implicit_wait = 30

        @time = Time.now
        @str_name = @time.year.to_s + @time.month.to_s + @time.day.to_s + @time.hour.to_s + @time.min.to_s

        @register_page = RegisterPage.new :driver => @driver , :base_url => @base_url
        @register_page.choose_your_plan('free_plan')
        @register_page.choose_how_to_sign_in('register_adobeid')
        @driver.switch_to.frame(0)
        sleep 5
        register_locator(:adobe_id_frame_create_adobe_id_btn).click
        sleep 5

        @user_info = {
            :email_address =>   "pgbtesttiing_" + @time.year.to_s + @time.month.to_s + @time.day.to_s + "@g990mail.com",
            :password =>        "pgbtesting001",
            :retype_pass =>     "pgbtesting001",
            :first_name =>      "pgb",
            :last_name =>       "testing",
            :country_region =>  "JP"
        }
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

    it "IT_001: Got an error message with invalid Adobe ID (Email Address)" do
        user = @user_info.clone
        user[:email_address] = $data[:user][$lang][:invalid_user][:id]
        sleep 5
        warnings = @register_page.enter_register_information(user)
        warnings.should eql $data[:str][$lang][:PGB_enter_a_valid_email]
    end

    it "IT_002: Got an error message with unmatched password" do 
        user = @user_info.clone
        user[:retype_pass] = "something_not_the_original_password"
        sleep 5
        warnings = @register_page.enter_register_information(user)
        warnings.should eql $data[:str][$lang][:PGB_retyped_password_unmatched]
    end

    it "IT_003: Got an error message with invalid First Name" do 
        user = @user_info.clone
        user[:first_name] = "ſЊџЛ^&*!@##@яѨ҉ҝҾ"
        
        warnings = @register_page.enter_register_information(user)
        sleep 5
        warnings.should eql $data[:str][$lang][:PGB_first_name_invalid]
    end

    it "IT_004: Got an error message with invalid Last Name" do 
        user = @user_info.clone
        user[:last_name] = "ſЊџЛ^&*!@##@яѨ҉ҝҾ"
        
        warnings = @register_page.enter_register_information(user)
        sleep 5
        warnings.should eql $data[:str][$lang][:PGB_last_name_invalid]
    end

    it "IT_005: Got an error message without a country selected" do
        user = @user_info.clone
        user[:country_region] =""
        
        warnings = @register_page.enter_register_information(user)
        sleep 5
        warnings.should eql $data[:str][$lang][:PGB_without_selecting_country]
    end

    it "IT_006: page direct to '/apps' page after successfully new Adobe ID was created with valid appropriate email and password" do 
        @user = @user_info.clone
        @user[:email_address] ="dil45216+test_" + @str_name + "@adobetest.com"
        @user[:password] = "password"
        @user[:retype_pass] = "password"

        @register_page.enter_register_information(@user)
        sleep 5
        @register_page.have_read_and_agree
        sleep 15
        @driver.current_url.should eql @base_url + $data[:url][:sign_in_successfully]
    end

end

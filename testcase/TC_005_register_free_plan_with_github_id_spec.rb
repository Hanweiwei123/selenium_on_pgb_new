#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative '../action/register_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/register_locator'
require_relative '../util/dialog_locator/header_footer_locator'

# This TC describes:
#   situations trying to register github free account to sign in. 
describe "TC_005: Register an free plan account with Github ID" do 
    include RegisterLocator
    include ConfigParam
    include WebdriverHelper
    include HeaderFooterLocator

    before(:all) do 
        init
        @order_of_it = WebdriverHelper::Counter.new
        @name_screenshot = "TC_005_IT_"
        @base_url = "https://buildstage.phonegap.com"
    end

    after(:all) do 
        begin
            go_to_page_edit_account
            @driver.execute_script("document.getElementById('delete-account').style['display'] = 'block'")
            @driver.find_element(:xpath => "//*[@id='delete-account']/section/fieldset/a").click  
            @driver.switch_to.alert.accept
        ensure
            
        end
    end

    before(:each) do 
        @driver = driver
		@driver.manage.window.maximize
        @driver.get path_format_locale("/plans/free", @base_url)
        register_locator(:github_btn).click; sleep 10
    end

    after(:each) do  # Take screenshot in case of failure
        begin
            @name_screenshot += @order_of_it.inc.to_s
            if example.exception != nil
                take_screenshot_with_name @name_screenshot
            end
        ensure
            @driver.quit
        end
    end

    it "IT_001: direct to '/apps' page when sign in successfully with github id(which is connected to pgb), " do 
        fill_in register_locator(:github_login_username_input), :with => $data[:user][$lang][:github_id_only][:id]
        fill_in register_locator(:github_login_password_input), :with => $data[:user][$lang][:github_id_only][:password]
        register_locator(:github_login_submit_btn).click;  sleep 10
        
        @driver.current_url.should eql @base_url + $data[:url][:sign_in_successfully]
        sign_out
    end

    it "IT_002: Got an error message('Existing Registration Found') when use account that can log in both. " do  
        fill_in register_locator(:github_login_username_input), :with => $data[:user][$lang][:email_that_login_both][:id]
        fill_in register_locator(:github_login_password_input), :with => $data[:user][$lang][:email_that_login_both][:password]
        register_locator(:github_login_submit_btn).click; sleep 5
        register_locator(:existing_registration_found_warning).text.should eql $data[:str][$lang][:PGB_existing_registration_found]
    end

    it "IT_003: Got an error message when proceed without selecting a country" do 
        fill_in register_locator(:github_login_username_input), :with => $data[:user][$lang][:adobe_id_free_final_step][:id]
        fill_in register_locator(:github_login_password_input), :with => $data[:user][$lang][:adobe_id_free_final_step][:password]
        register_locator(:github_login_submit_btn).click; sleep 5
        @current_url = @driver.current_url
        puts "+<current_url> is #{@current_url}"
        if(@current_url.include? "https://github.com/login/oauth/")
          register_locator(:github_allow_access_btn).click
          sleep 3
        end
        register_locator(:github_accept_the_adobe_terms).click
        register_locator(:github_complete_my_registration).click; sleep 3
        register_locator(:github_warning_message).text.should eql $data[:str][$lang][:PGB_alert_you_must_select_a_country]
    end

    it "IT_004: Got an error message when proceed without agree to the terms of service" do 
        fill_in register_locator(:github_login_username_input), :with => $data[:user][$lang][:adobe_id_free_final_step][:id]
        fill_in register_locator(:github_login_password_input), :with => $data[:user][$lang][:adobe_id_free_final_step][:password]
        register_locator(:github_login_submit_btn).click; sleep 5
        register_locator(:github_select_a_country).find_elements(:tag_name => "option").each do |country| 
            if(country.text == "Japan") 
                country.click
                break
            end
        end
        register_locator(:github_complete_my_registration).click; sleep 3
        register_locator(:github_warning_message).text.should eql $data[:str][$lang][:PGB_you_mush_agree_to_the_terms_of_service]
    end

    it "IT_005: page direct to '/apps' after sign in successfully with valid appropriate account . " do 
        fill_in register_locator(:github_login_username_input), :with => $data[:user][$lang][:adobe_id_free_final_step][:id]
        fill_in register_locator(:github_login_password_input), :with => $data[:user][$lang][:adobe_id_free_final_step][:password]
        register_locator(:github_login_submit_btn).click; sleep 5
        register_locator(:github_select_a_country).find_elements(:tag_name => "option").each do |country| 
            if(country.text == "United States") 
                country.click
                break
            end
        end
        register_locator(:github_accept_the_adobe_terms).click
        register_locator(:github_complete_my_registration).click; sleep 10
        @driver.current_url.should eql @base_url + $data[:url][:sign_in_successfully]
    end

end

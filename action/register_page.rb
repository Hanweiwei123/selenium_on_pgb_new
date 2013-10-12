#encoding: utf-8

require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/register_locator"

class RegisterPage
    include ConfigParam
    include WebdriverHelper
    include RegisterLocator

    def initialize(options = {})
      raise "Must pass a hash containing ':driver'" if not options.is_a?(Hash) or not options.has_key?(:driver)

      @driver = options.delete(:driver)
      @driver.manage.window.maximize
      if not options.has_key?(:base_url)
        @base_url = $base_url
      else
        @base_url = options.delete(:base_url)
      end
      puts "+ <action> RegisterPage#initialize "
    end

    def choose_your_plan(plan)
      make_sure_plans_page
      case plan 
      when /.*free.*/ 
        register_locator(:free_plan_link).click
      when /.*paid.*/
        register_locator(:paid_plan_link).click
      when /.*ccm.*/
        register_locator(:adobe_ccm_link).click
      else
        raise "Available plan were: ['free_plan', 'paid_plan', 'adobe_ccm']"
      end
      puts "+ <action>/RegisterPage#choose_your_plan :#{plan}"
    end

    def choose_how_to_sign_in(how)
      case how.to_s.downcase
      when /.*adobe.*/
        register_locator(:adobe_id_btn).click
      when /.*github.*/
        register_locator(:github_btn).click
      else
        raise "Available choises: :adobe_id_btn, "
      end
      puts "+ <action>/RegisterPage#choose_how_to_sign_in :#{how}"
    end

    # Fill in the register form by providing a array which contains 
    # user-related informations like: email address, password, first name, last name, and coutry-region. 
    # methods: "adobe_id_frame_*" were defined in register_dialog.rb located in "tools/"
    def enter_register_information(user) 
        puts "+ <action> enter_register_information --- begin"
        fill_in register_locator(:adobe_id_frame_email_address), :with => user[:email_address]
        fill_in register_locator(:adobe_id_frame_password), :with => user[:password]
        fill_in register_locator(:adobe_id_frame_retype_password), :with => user[:retype_pass]
        fill_in register_locator(:adobe_id_frame_firstname_input), :with => user[:first_name]
        fill_in register_locator(:adobe_id_frame_lastname_input), :with => user[:last_name]
        select_region register_locator(:adobe_id_frame_country_region_select), :with => user[:country_region]

        register_locator(:adobe_id_frame_create_account_btn).click
        sleep 5
        puts "+ <action> enter_register_information --- end"

        if warning_display? 
            return register_locator(:adobe_id_frame_warning_message).text
        end

    end

    # Just help to click the 'Accept' btn. 
    def have_read_and_agree
        register_locator(:adobe_id_frame_read_and_agree_the_term_checkbox).click
        register_locator(:adobe_id_frame_accept_btn).click
        puts "+ <action>/RegisterPage#have_read_and_agree "
    end

    # There are warnings
    # This helper tool helps to detect if warning message appears. 
    def warning_display?
        begin
            register_locator(:adobe_id_frame_warning_message)
            true
        rescue Selenium::WebDriver::Error::NoSuchElementError
            false
        end
    end

    def make_sure_plans_page
      go_to_page :register_page,@base_url unless @driver.current_url =~ /.*\/plans$/
      puts "+ <action>/RegisterPage#make_sure_plans_page"
    end
end

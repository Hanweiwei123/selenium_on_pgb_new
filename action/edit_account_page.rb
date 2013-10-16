#encoding: utf-8
# operations at page "/people/edit" -> Tab "Signing Keys" 

require_relative "../action/sign_in_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative '../util/dialog_locator/edit_account_locator'
require_relative '../util/dialog_locator/header_footer_locator'

class EditAccountPage
    include EditAccountLocator
    include ConfigParam
    include WebdriverHelper
    include HeaderFooterLocator

    attr_reader :user, :base_url

    def initialize(options = {})
        puts "+ <action><edit_account_page> initialize EditAccountPage -- begin"
        raise "Must pass a hash containing ':user'" if not options.is_a?(Hash) or not options.has_key?(:user) 
        raise "Must pass a hash containing ':driver'" if not options.is_a?(Hash) or not options.has_key?(:driver) 
        if not options.has_key?(:base_url)
          @base_url = $config[:base_url]
        else
          @base_url = options.delete(:base_url)
        end

        @driver = options.delete(:driver)
        @user = options.delete(:user)
        @user_id = @user.delete(:id)
        @user_password = @user.delete(:password)

        @sign_in_page = SignInPage.new :driver => @driver, :base_url => @base_url, :user => {:id => @user_id.to_s, :password => @user_password.to_s }
        puts "+ <action><edit_account_page> initialize EditAccountPage -- end"
    end

    def enter_github_account_and_sign_in_with(id, password)
        fill_in ea_account_details(:github_login_username_input), :with => id
        fill_in ea_account_details(:github_login_password_input), :with => password
        ea_account_details(:github_login_submit_btn).click; sleep 10
    end

    def add_ios_signing_key valideOne_or_invalidOne = "valid"
        type = valideOne_or_invalidOne.upcase
        if(type == "VALID")
            title = $data[:signing_key][:ios][:name_valid]
        else
            title = $data[:signing_key][:ios][:name_invalid]
        end
        os = win_or_mac                              
        puts "+ <action><edit_account_page> os: #{os}"
        puts "+ <action><edit_account_page> add_iOS_signing_key of #{type}  -- begin"

        make_sure_signing_keys_tab

        ea_signing_keys(:ios_add_key_btn).click
        ea_signing_keys(:ios_title_input).send_keys(title)
        if(os == "win")
            ea_signing_keys(:ios_choose_cert_file_btn).send_keys("C:\\assets\\signing_key\\ios\\LichuanIQEKey.p12")
            ea_signing_keys(:ios_choose_prov_file_btn).send_keys("C:\\assets\\signing_key\\ios\\Lichuanlu.mobileprovision")
        else
            ea_signing_keys(:ios_choose_cert_file_btn).send_keys(File.expand_path($data[:signing_key][:ios][:valid][:cert],__FILE__))
            ea_signing_keys(:ios_choose_prov_file_btn).send_keys(File.expand_path($data[:signing_key][:ios][:valid][:profile],__FILE__))
        end
        ea_signing_keys(:ios_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> add_iOS_signing_key of #{type}  -- end"
    end

    def to_make_1st_signing_key_default
        make_sure_signing_keys_tab
        ea_signing_keys(:ios_1st_default_btn).click
    end

    def to_make_2nd_signing_key_default
        make_sure_signing_keys_tab
        ea_signing_keys(:ios_2nd_default_btn).click
    end
    
    def to_unlock_1st_ios_signing_key
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 1st iOS signing_key --- begin"
        ea_signing_keys(:ios_1st_lock_btn).click
        # ios_1st_lock_btn.click
        sleep 5
        ea_signing_keys(:ios_1st_cert_password_input).send_keys $data[:signing_key][:ios][:cert_password]
        ea_signing_keys(:ios_1st_cert_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 1st iOS signing_key --- end"
    end

    def to_unlock_1st_ios_signing_key_with_invalid_password
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 1st iOS signing_key with INVALID password  --- begin"
        ea_signing_keys(:ios_1st_lock_btn).click
        ea_signing_keys(:ios_1st_cert_password_input).send_keys "xxxxxxx"
        ea_signing_keys(:ios_1st_cert_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 1st iOS signing_key with INVALID password  --- end"
    end

    def get_status_of_1st_ios_signing_key
        make_sure_signing_keys_tab
        Selenium::WebDriver::Wait.new(:timeout => 60).until { ea_signing_keys(:ios_1st_lock_btn) } 
        return ea_signing_keys(:ios_1st_lock_btn).attribute("title")
    end

    def to_unlock_2nd_ios_signing_key
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd iOS signing_key --- begin"
        ea_signing_keys(:ios_2nd_lock_btn).click
        ea_signing_keys(:ios_2nd_cert_password_input).send_keys $data[:signing_key][:ios][:cert_password]
        ea_signing_keys(:ios_2nd_cert_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd iOS signing_key --- end"
    end

    def to_unlock_2nd_ios_signing_key_with_invalid_password
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd iOS signing_key with INVALID password --- begin"
        ea_signing_keys(:ios_2nd_lock_btn).click
        ea_signing_keys(:ios_2nd_cert_password_input).send_keys "xxxxxxx"
        ea_signing_keys(:ios_2nd_cert_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd iOS signing_key with INVALID password --- end"
    end

    def get_status_of_2nd_ios_signing_key
        make_sure_signing_keys_tab
        Selenium::WebDriver::Wait.new(:timeout => 20).until { ea_signing_keys(:ios_2nd_lock_btn) } 
        return ea_signing_keys(:ios_2nd_lock_btn).attribute("title")
    end

    def delete_1st_ios_signing_key
        make_sure_signing_keys_tab
        go_to_page(:edit_account, @base_url)
        ea_signing_keys(:signing_keys_tab).click

        ea_signing_keys(:ios_1st_delete_btn).click
        @driver.switch_to.alert.accept
        puts "+ <action><edit_account_page> --- delete_1st_iOS_signing_key DONE"
    end

    def delete_2nd_ios_signing_key
        make_sure_signing_keys_tab
        ea_signing_keys(:ios_2nd_delete_btn).click
        @driver.switch_to.alert.accept
        puts "+ <action><edit_account_page> --- delete_2nd_iOS_signing_key DONE"
    end

    def add_android_signing_key valideOne_or_invalidOne    
        type = valideOne_or_invalidOne.upcase
        if type == "VALID" 
            android_title = $data[:signing_key][:android][:name_valid]
            android_alias = $data[:signing_key][:android][:name_valid]
        else
            android_title = $data[:signing_key][:android][:name_invalid]
            android_alias = $data[:signing_key][:android][:name_invalid]
        end
        os = win_or_mac
        puts "+ <action><edit_account_page> os: #{os}"
        puts "+ <action><edit_account_page> add_Android_signing_key of #{type}  -- begin"

        make_sure_signing_keys_tab

        ea_signing_keys(:android_add_key_btn).click
        ea_signing_keys(:android_title_input).send_keys android_title
        ea_signing_keys(:android_alias_input).send_keys android_alias
        if(os == "win")
            ea_signing_keys(:android_choose_keystore_btn).send_keys("C:\\assets\\signing_key\\android\\android-dilato.keystore")
        else
            ea_signing_keys(:android_choose_keystore_btn).send_keys(File.expand_path($data[:signing_key][:android][:valid][:keystore],__FILE__))            
        end
        ea_signing_keys(:android_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> add_Android_signing_key of #{type}  -- end"
    end

    def to_unlock_1st_android_signing_key
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 1st ANDROID signing_key --- begin"
        ea_signing_keys(:android_1st_lock_btn).click
        ea_signing_keys(:android_1st_cert_password_input).send_keys $data[:signing_key][:android][:cert_password]
        ea_signing_keys(:android_1st_keystore_password_input).send_keys $data[:signing_key][:android][:keystore_password]
        ea_signing_keys(:android_1st_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 1st ANDROID signing_key --- end"
    end

    def to_unlock_1st_android_signing_key_with_invalid_password
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 1st ANDROID signing_key with INVALID password --- begin"
        ea_signing_keys(:android_1st_lock_btn).click
        ea_signing_keys(:android_1st_cert_password_input).send_keys "xxxxxxx"
        ea_signing_keys(:android_1st_keystore_password_input).send_keys "xxxxxxx"
        ea_signing_keys(:android_1st_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 1st ANDROID signing_key with INVALID password --- end"
    end

    def get_status_of_1st_android_signing_key
        make_sure_signing_keys_tab
        Selenium::WebDriver::Wait.new(:timeout => 20).until { ea_signing_keys(:android_1st_lock_btn) } 
        return ea_signing_keys(:android_1st_lock_btn).attribute("title")
    end

    def to_unlock_2nd_android_signing_key
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd ANDROID signing_key --- begin"
        ea_signing_keys(:android_2nd_lock_btn).click
        ea_signing_keys(:android_2nd_cert_password_input).send_keys $data[:signing_key][:android][:cert_password]
        ea_signing_keys(:android_2nd_keystore_password_input).send_keys $data[:signing_key][:android][:keystore_password]
        ea_signing_keys(:android_2nd_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd ANDROID signing_key --- end"
    end

    def to_unlock_2nd_android_signing_key_with_invalid_password
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd ANDROID signing_key with INVALID password --- begin"
        ea_signing_keys(:android_2nd_lock_btn).click
        ea_signing_keys(:android_2nd_cert_password_input).send_keys "xxxxxxx"
        ea_signing_keys(:android_2nd_keystore_password_input).send_keys "xxxxxxx"
        ea_signing_keys(:android_2nd_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd ANDROID signing_key with INVALID password --- end"
    end

    def get_status_of_2nd_android_signing_key
        make_sure_signing_keys_tab
        Selenium::WebDriver::Wait.new(:timeout => 20).until { ea_signing_keys(:android_2nd_lock_btn) } 
        return ea_signing_keys(:android_2nd_lock_btn).attribute("title")
    end

    def delete_1st_android_signing_key
        make_sure_signing_keys_tab
        ea_signing_keys(:android_1st_delete_btn).click
        @driver.switch_to.alert.accept
        puts "+ <action><edit_account_page> --- delete_1st_ANDROID_signing_key DONE"
    end

    def delete_2nd_android_signing_key
        make_sure_signing_keys_tab
        ea_signing_keys(:android_2nd_delete_btn).click
        @driver.switch_to.alert.accept
        puts "+ <action><edit_account_page> --- delete_2nd_ANDROID_signing_key DONE"
    end

    def add_blackberry_signing_key valideOne_or_invalidOne
        type = valideOne_or_invalidOne.upcase
        if type == "VALID" 
            blackberry_title = $data[:signing_key][:blackberry][:name_valid]
        else
            blackberry_title = $data[:signing_key][:blackberry][:name_invalid]
        end
        os = win_or_mac
        puts "+ <action><edit_account_page> os: #{os}"
        puts "+ <action><edit_account_page> add_BlackBerry_signing_key of #{type}  -- begin"
        make_sure_signing_keys_tab
        ea_signing_keys(:blackberry_add_key_btn).click
        ea_signing_keys(:blackberry_title_input).send_keys blackberry_title
        if(os == "win")
            ea_signing_keys(:blackberry_choose_csk_btn).send_keys("C:\\assets\\signing_key\\blackberry\\sigtool.csk")
            ea_signing_keys(:blackberry_choose_db_btn).send_keys("C:\\assets\\signing_key\\blackberry\\sigtool.db")
        else
            ea_signing_keys(:blackberry_choose_csk_btn).send_keys File.expand_path($data[:signing_key][:blackberry][:valid][:csk],__FILE__)
            ea_signing_keys(:blackberry_choose_db_btn).send_keys File.expand_path($data[:signing_key][:blackberry][:valid][:db],__FILE__)
        end
        ea_signing_keys(:blackberry_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> add_BlackBerry_signing_key of #{type}  -- end"
    end

    def to_unlock_1st_blackberry_signing_key
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 1st BLACKBERRY signing_key --- begin"
        ea_signing_keys(:blackberry_1st_lock_btn).click
        ea_signing_keys(:blackberry_1st_key_password_input).send_keys $data[:signing_key][:blackberry][:key_password]
        ea_signing_keys(:blackberry_1st_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 1st BLACKBERRY signing_key --- end"
    end

    def to_unlock_1st_blackberry_signing_key_with_invalid_password
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 1st BLACKBERRY signing_key with INVALID password --- begin"
        ea_signing_keys(:blackberry_1st_lock_btn).click
        ea_signing_keys(:blackberry_1st_key_password_input).send_keys "xxxxxxx"
        ea_signing_keys(:blackberry_1st_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 1st BLACKBERRY signing_key with INVALID password --- end"
    end

    def get_status_of_1st_blackberry_signing_key
        make_sure_signing_keys_tab
        Selenium::WebDriver::Wait.new(:timeout => 20).until { ea_signing_keys(:blackberry_1st_lock_btn) } 
        return ea_signing_keys(:blackberry_1st_lock_btn).attribute("title")
    end

    def to_unlock_2nd_blackberry_signing_key
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd BLACKBERRY signing_key --- begin"
        ea_signing_keys(:blackberry_2nd_lock_btn).click
        ea_signing_keys(:blackberry_2nd_key_password_input).send_keys $data[:signing_key][:blackberry][:key_password]
        ea_signing_keys(:blackberry_2nd_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd BLACKBERRY signing_key --- end"
    end

    def to_unlock_2nd_blackberry_signing_key_with_invalid_password
        make_sure_signing_keys_tab
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd BLACKBERRY signing_key with INVALID password --- begin"
        ea_signing_keys(:blackberry_2nd_lock_btn).click
        ea_signing_keys(:blackberry_2nd_key_password_input).send_keys "xxxxxxx"
        ea_signing_keys(:blackberry_2nd_submit_btn).click
        sleep 5
        puts "+ <action><edit_account_page> --- to UNLOCK 2nd BLACKBERRY signing_key with INVALID password --- end"
    end

    def get_status_of_2nd_blackberry_signing_key
        make_sure_signing_keys_tab
        Selenium::WebDriver::Wait.new(:timeout => 20).until { ea_signing_keys(:blackberry_2nd_lock_btn) } 
        return ea_signing_keys(:blackberry_2nd_lock_btn).attribute("title")
    end

    def delete_1st_blackberry_signing_key
        make_sure_signing_keys_tab
        ea_signing_keys(:blackberry_1st_delete_btn).click
        @driver.switch_to.alert.accept
        puts "+ <action><edit_account_page> --- delete_1st_BLACKBERRY_signing_key DONE"
    end

    def delete_2nd_blackberry_signing_key
        make_sure_signing_keys_tab
        ea_signing_keys(:blackberry_2nd_delete_btn).click
        @driver.switch_to.alert.accept
        puts "+ <action><edit_account_page> --- delete_2nd_BLACKBERRY_signing_key DONE"
    end

    def get_status_signing_key(title ,platform)
      make_sure_signing_keys_tab
      ele=highlight_and_return @driver.find_element(:xpath => "//fieldset[@id='person-keys']/table[contains(@data-platform,'#{platform}')]/tbody/tr[td[contains(text(),'#{title}')]]/td[3]/a")
      return ele.attribute("title")
      #  //fieldset[@id='person-keys']/table[contains(@data-platform,'ios')]/tbody/tr[td[contains(text(),'dd')]]/td[3]/a
    end

# --- 
    def make_sure_account_details_tab
        make_sure_ea_page
        ea_account_details(:account_details_tab).click
    end

    def make_sure_private_codehosting_tab
        make_sure_ea_page
        ea_private_ch(:private_code_hosting_tab).click
    end

    def make_sure_signing_keys_tab
        make_sure_ea_page
        ea_signing_keys(:signing_keys_tab).click
    end

    def make_sure_ea_page
        (@sign_in_page.make_sure_sign_in;
        go_to_page_edit_account;)unless @driver.current_url.include?('edit')
    end

    def delete_my_account(id, password)
        @sign_in_page.make_sure_sign_in
        go_to_page :edit_account , @base_url
        @driver.execute_script("document.getElementById('delete-account').style['display'] = 'block'")
        puts "+ after executing script"
        sleep 5
        
        @driver.find_element(:xpath => "//*[@id='delete-account']/section/fieldset/a").click  
        @driver.switch_to.alert.accept

        sleep 5
        puts "+ user account #{id} deleted"
    end
end

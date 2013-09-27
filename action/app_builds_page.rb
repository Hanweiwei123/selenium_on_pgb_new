#encoding: utf-8

require_relative "../util/dialog_locator/app_id_locator"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"

class AppBuildsPage
    include AppIdLocator
    include NewAppLocator
    include WebdriverHelper

    def initialize(options = {})
        @os = win_or_mac
        raise "Must pass a hash containing ':user'" if not options.is_a?(Hash) or not options.has_key?(:user) 
        raise "Must pass a hash containing ':driver'" if not options.is_a?(Hash) or not options.has_key?(:driver) 
        if not options.has_key?(:base_url)
          @base_url = $config[:base_url]
        else
          @base_url = options.delete(:base_url)
        end

        @driver = options.delete(:driver)
        @data_user = options.delete(:user)
        @user_id = @data_user.delete(:id)
        @user_password = @data_user.delete(:password)

        @sign_in_page = SignInPage.new :driver => @driver, :user => {:id => @user_id.to_s, :password => @user_password.to_s }
    end
    
# --- iOS
    def ios_add_signing_key valideOne_or_invalidOne = "valid"
        type = valideOne_or_invalidOne.upcase
        if(type == "VALID")
          title = $data[:signing_key][:ios][:name_valid]
        else
          title = $data[:signing_key][:ios][:name_invalid]
        end
        os = win_or_mac
        browser = ENV['PGBBROWSER'].to_sym
        if browser == :firefox
          builds(:ios_options_firefox).click; sleep 2
        else
          builds(:ios_options).click; sleep 2
        end
        builds(:ios_new_key).click; sleep 2
        if is_element_present(:app_builds_page,:ios_title_input)
          builds(:ios_title_input).clear
          builds(:ios_title_input).send_keys title
          if ( os == "win" )
            builds(:ios_choose_cert_btn).send_keys("C:\\assets\\signing_key\\ios\\LichuanIQEKey.p12")
            builds(:ios_choose_prov_btn).send_keys("C:\\assets\\signing_key\\ios\\Lichuanlu.mobileprovision")
          else
            builds(:ios_choose_cert_btn).send_keys(File.expand_path($data[:signing_key][:ios][:valid][:cert],__FILE__))
            builds(:ios_choose_prov_btn).send_keys(File.expand_path($data[:signing_key][:ios][:valid][:profile],__FILE__))
          end
          sleep 2
          if is_element_present(:app_builds_page,:ios_submit_btn)
            builds(:ios_submit_btn).click
          end
          sleep 5
        end
    end

    def ios_get_error_msg_of_the_signing_key
        timeout(120) {
          while $data[:str][$lang][:builds_action_pending] == builds(:ios_action).text do
            @driver.navigate.refresh
            sleep 5
            puts "+ action: " + builds(:ios_action).text
          end
        }
        if builds(:ios_action).text == $data[:str][$lang][:builds_action_error]
          builds(:ios_action).click; sleep 5
          if is_element_present(:app_builds_page,:ios_msg)
            sleep 2
            return builds(:ios_msg).text
          end
        else
          puts "+ action: " + builds(:ios_action).text
          return "false"
        end
    end

    def to_unlock_ios_signing_key valideOne_or_invalidOne = "valid"
        type = valideOne_or_invalidOne.upcase
        if(type == "VALID")
          key_password = $data[:signing_key][:ios][:cert_password]
        else
          key_password = "INVALID"
        end
        timeout(60) {
          while $data[:str][$lang][:builds_action_pending] == builds(:ios_action).text do
            @driver.navigate.refresh
            sleep 5
            puts "+ action: " + builds(:ios_action).text
          end
        }
        if is_element_present(:app_builds_page,:ios_status)
          builds(:ios_status).click; sleep 5
          builds(:ios_unlock_cert_pwd_input).send_keys key_password
          builds(:ios_unlock_submit_btn).click; sleep 5
        end
    end

    def ios_get_signing_key_name_of_id(id)
        puts "+ <action><app_builds_page> iOS: Trying to get name of signing-key{id: #{id}} "
        puts "+ @base_url = #{@base_url}"
        private_resource = RestClient::Resource.new(
            "#{@base_url}/api/v1/apps/#{id}", 
            :user => @data_user[$lang][:adobe_id_free_002][:id] , 
            :password => @data_user[$lang][:adobe_id_free_002][:password], 
            :timeout => 60)
        response = private_resource.get :accept => :json
        json =  JSON.parse(response)

        keys = json['keys']['ios']
        if keys == nil 
            return "" 
        else
            return keys['title']
        end
        
    end
# --- /iOS

# --- Android
    def android_add_signing_key valideOne_or_invalidOne = "valid"
      type = valideOne_or_invalidOne.upcase
      if(type == "VALID")
        title = $data[:signing_key][:android][:name_valid]
      else
        title = $data[:signing_key][:android][:name_invalid]
      end
      os = win_or_mac
      browser = ENV['PGBBROWSER'].to_sym
      if browser == :firefox
        builds(:android_options_firefox).click; sleep 2
      else
        builds(:android_options).click; sleep 2
      end
      builds(:android_new_key).click; sleep 2
      if is_element_present(:app_builds_page,:android_title_input)
        builds(:android_title_input).clear
        builds(:android_title_input).send_keys title
        builds(:android_alias).clear
        builds(:android_alias).send_keys $data[:signing_key][:android][:Ailas]
        if ( os == "win" )
          builds(:android_choose_keystore_btn).send_keys("C:\\assets\\signing_key\\android\\android-dilato.keystore")
        else
          builds(:android_choose_keystore_btn).send_keys(File.expand_path($data[:signing_key][:android][:valid][:keystore],__FILE__))
        end
        sleep 2
        if is_element_present(:app_builds_page,:android_submit_btn)
          builds(:android_submit_btn).click
        end
        sleep 5
      end
    end

    def android_get_error_msg_of_the_signing_key
      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:android_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:android_action).text
        end
      }
      if builds(:android_action).text == $data[:str][$lang][:builds_action_error]
        builds(:android_action).click; sleep 5
        if is_element_present(:app_builds_page,:android_msg)
          sleep 2
          return builds(:android_msg).text
        end
      else
        puts "+ action: " + builds(:android_action).text
        return "false"
      end
    end

    def to_unlock_android_signing_key valideOne_or_invalidOne = "valid"
      type = valideOne_or_invalidOne.upcase
      if(type == "VALID")
        cert_password = $data[:signing_key][:android][:cert_password]
        keystore_password = $data[:signing_key][:android][:keystore_password]
      else
        cert_password = "INVALID"
        keystore_password  = "INVALID"
      end
      timeout(60) {
        while $data[:str][$lang][:builds_action_pending] == builds(:android_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:android_action).text
        end
      }
      if is_element_present(:app_builds_page,:android_status)
        builds(:android_status).click; sleep 5
        builds(:android_unlock_cert_pwd_input).send_keys cert_password
        builds(:android_unlock_keystore_pwd_input).send_keys keystore_password
        builds(:android_unlock_submit_btn).click
      end
    end

    def android_get_signing_key_name_of(id)
        puts "+ <action><app_builds_page> Android: Trying to get name of signing-key{id: #{id}} "
        puts "+ @base_url = #{@base_url}"
        sleep 10
        private_resource = RestClient::Resource.new(
            "#{@base_url}/api/v1/apps/#{id}", 
            :user => @data_user[$lang][:adobe_id_free_002][:id] , 
            :password => @data_user[$lang][:adobe_id_free_002][:password] , 
            :timeout => 60)
        response = private_resource.get :accept => :json
        json =  JSON.parse(response)
        keys = json['keys']['android']
        if keys == nil 
            return ""
        else
            return keys['title']
        end
    end
# --- /Android

# --- BlackBerry
    def blackberry_add_signing_key valideOne_or_invalidOne = "valid"
      type = valideOne_or_invalidOne.upcase
      if(type == "VALID")
        title = $data[:signing_key][:blackberry][:name_valid]
      else
        title = $data[:signing_key][:blackberry][:name_invalid]
      end
      os = win_or_mac
      browser = ENV['PGBBROWSER'].to_sym
      if browser == :firefox
        builds(:blackberry_options_firefox).click; sleep 2
      else
        builds(:blackberry_options).click; sleep 2
      end
      builds(:blackberry_new_key).click; sleep 2
      if is_element_present(:app_builds_page,:blackberry_title_input)
        builds(:blackberry_title_input).clear
        builds(:blackberry_title_input).send_keys title
        if(os == "win")
          builds(:blackberry_choose_csk_btn).send_keys("C:\\assets\\signing_key\\blackberry\\sigtool.csk")
          builds(:blackberry_choose_db_btn).send_keys("C:\\assets\\signing_key\\blackberry\\sigtool.db")
        else
          builds(:blackberry_choose_csk_btn).send_keys File.expand_path($data[:signing_key][:blackberry][:valid][:csk],__FILE__)
          builds(:blackberry_choose_db_btn).send_keys File.expand_path($data[:signing_key][:blackberry][:valid][:db],__FILE__)
        end
        sleep 2
        if is_element_present(:app_builds_page,:blackberry_submit_btn)
          builds(:blackberry_submit_btn).click
        end
        sleep 5
      end
    end

    def blackberry_get_error_msg_of_the_signing_key
      timeout(120) {
        while $data[:str][$lang][:builds_action_pending] == builds(:blackberry_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:blackberry_action).text
        end
      }
      if builds(:blackberry_action).text == $data[:str][$lang][:builds_action_error]
        builds(:blackberry_action).click; sleep 5
        if is_element_present(:app_builds_page,:blackberry_msg)
          sleep 2
          return builds(:blackberry_msg).text
        end
      else
        puts "+ action: " + builds(:blackberry_action).text
        return "false"
      end
    end

    def to_unlock_blackberry_signing_key valideOne_or_invalidOne = "valid"
      type = valideOne_or_invalidOne.upcase
      if(type == "VALID")
        key_password = $data[:signing_key][:blackberry][:key_password]
      else
        key_password = "INVALID8"
      end
      timeout(60) {
        while $data[:str][$lang][:builds_action_pending] == builds(:blackberry_action).text do
          @driver.navigate.refresh
          sleep 5
          puts "+ action: " + builds(:blackberry_action).text
        end
      }
      if is_element_present(:app_builds_page,:blackberry_status)
        builds(:blackberry_status).click; sleep 5
        builds(:blackberry_unlock_password_input).send_keys key_password
        builds(:balckberry_unlock_submit_btn).click
      end
    end

    def blackberry_get_signing_key_name_of id 
        puts "+ <action><app_builds_page> BlackBerry: Trying to get name of signing-key{id: #{id}} "
        puts "+ @base_url = #{@base_url}"
        sleep 10
        private_resource = RestClient::Resource.new(
            "#{@base_url}/api/v1/apps/#{id}", 
            :user => @data_user[$lang][:adobe_id_free_002][:id] , 
            :password => @data_user[$lang][:adobe_id_free_002][:password] , 
            :timeout => 60)
        response = private_resource.get :accept => :json
        json =  JSON.parse(response)
        keys = json['keys']['blackberry']
        if keys == nil 
            return ""
        else
            return keys['title']
        end
    end
# --- /BlackBerry

end

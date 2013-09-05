#encoding: utf-8

require_relative "../action/sign_in_page"
require_relative "../util/dialog_locator/new_app_locator"
require_relative "../util/webdriver_helper"
require_relative "../util/config_param"

class NewAppPage
    include NewAppLocator
    include WebdriverHelper
    include ConfigParam

    attr_reader :user, :base_url

    def initialize(options = {})
        puts "+ <action> initialize NewAppPage -- begin"
        raise "Must pass a hash containing ':user'" if not options.is_a?(Hash) or not options.has_key?(:user) 
        raise "Must pass a hash containing ':driver'" if not options.is_a?(Hash) or not options.has_key?(:driver) 
        if not options.has_key?(:base_url)
          @base_url = $config[:base_url]
        else
          @base_url = options.delete(:base_url)
        end

        @driver = options.delete(:driver); @driver.manage.window.maximize
        @user = options.delete(:user)
        @user_id = @user.delete(:id)
        @user_password = @user.delete(:password)
        @sign_in_page = SignInPage.new :driver => @driver, :base_url => @base_url,:user => {:id => @user_id.to_s, :password => @user_password.to_s }

        puts "+ <action> initialize NewAppPage -- end"
    end

    # Get the number of existing apps by counting the number of tag 'article' 
    def number_of_existing_apps
        make_sure_apps_page unless @driver.current_url =~ /.*apps.*/
        num = @driver.find_elements(:tag_name => "article").count
        puts "+ <action> existing_app_num: #{num}"
        return num
    end

    # Get the ID of the top one of all apps
    # In order to compare it with new-created app's ID to verify if new app was created successfully. 
    def first_app_id
        make_sure_apps_page unless @driver.current_url =~ /.*apps.*/
        new_app_locator(:first_app_id).text
    end
    
    # On the default page after signing in
    # We can NOT see the '+ new app' button, if there aren't any existing apps.
    # We can see the '+ new app' btn, if there are existing apps. 
    # The '+ new app' btn opens the 'creating app' area, where we input information to create apps. 
    def new_app_btn_display?
        make_sure_apps_page unless @driver.current_url =~ /.*apps.*/
        style = new_app_locator(:new_app_btn).attribute("style")
        puts "------style---> #{style} <-------------"
        if style.chomp.include?("display: none;")
            sleep 5
            puts "+ <action> new_app_btn_display? NO"
            return false
        end
        sleep 5
        puts "+ <action> new_app_btn_display? YES"
        return true
    end

    # Detect whether another private app was able to be created. 
    # Return true if can not
    # Return false if can 
    def private_app_no?
        make_sure_apps_page unless @driver.current_url =~ /.*apps.*/
        disabled_or_not_upload =  new_app_locator(:upload_a_zip_btn).attribute('disabled') 
        disabled_or_not_paste = new_app_locator(:paste_git_repo_input).attribute('disabled') 
        if disabled_or_not_paste && disabled_or_not_upload
            puts "+ <action> private_app_no? NO"
            return true
        end
        puts "+ <action> private_app_no? YES"
        return false
    end

    # Create an (private) app by uploading a zip file, 
    # which contains files like: index.html, config.xml, *.js, *.css, and more related resource files. 
    # Steps are: 
    #       "private" tab -> "Upload a .zip file" 
    def new_app_with_zip
        puts "+ <action> New app with a zip file --- begin "
        make_sure_apps_page unless @driver.current_url =~ /.*apps.*/

        sleep 5
        if new_app_btn_display?
            new_app_locator(:new_app_btn).click;  sleep 2
        end

        new_app_locator(:private_repo_tab).click;  sleep 2

        if private_app_no?
            puts "+ <action> New app with a zip file --- end "
            return false
        end

        #excute javascript to show the element in order to magic uploading file
        @driver.execute_script("arguments[0].style.visibility = 'visible'; arguments[0].style.width = '1px';arguments[0].style.height = '1px';arguments[0].style.opacity = 1",new_app_locator(:upload_a_zip_btn))

        os = win_or_mac
        if os == 'mac' 
            # new_app_locator(:upload_a_zip_btn).send_keys (File.expand_path("../../assets/application/anotherあ你äōҾӲ.zip",__FILE__))
            new_app_locator(:upload_a_zip_btn).send_keys (File.expand_path("../assets/application/index.html",__FILE__))
        elsif os == 'win'
            # new_app_locator(:upload_a_zip_btn).send_keys "C:\\assets\\application\\www.zip"
            new_app_locator(:upload_a_zip_btn).send_keys "C:\\assets\\application\\index.html"
        else 
            railse "Not supported Operating System."
        end

        sleep 10
        # wait_for_element_present(:xpath, $data[:xpath][:sign_in_succ_page][:first_app_id])
        puts "+ <action> New app with a zip file --- end "
        return true
    end

    # Create an public app by submitting a github repo address. 
    # Steps are : 
    #       'open-source' tab -> "paste .git repo"  
    def new_public_app_with_repo
        puts "+ <action> New public app with github repo --- begin"
        make_sure_apps_page unless @driver.current_url =~ /.*apps.*/
        # Selenium::WebDriver::Wait.new(:timeout => 120).until { new_app_btn }
        sleep 10
        if new_app_btn_display?
            new_app_locator(:new_app_btn).click
        end
        new_app_locator(:opensource_repo_tab).click
        new_app_locator(:paste_git_repo_input).clear
        new_app_locator(:paste_git_repo_input).send_keys $data[:app][:new_app][:by_repo] + "\n"
        sleep 10
        puts "+ <action> New public app with github repo --- end"
    end

    # Create an private app by submitting a github repo address. 
    # Steps are:
    #       'private' tab -> 'paste .git repo'
    def new_private_app_with_repo
        puts "+ <action> New a private app with github repo --- begin" 
        make_sure_apps_page unless @driver.current_url =~ /.*apps.*/
        if new_app_btn_display?
            new_app_locator(:new_app_btn).click
        end
        new_app_locator(:private_repo_tab).click
        if !private_app_no?
            puts "+ <action> New a private app with github repo --- end" 
            new_app_locator(:paste_git_repo_input).send_keys $data[:app][:new_app][:by_repo] + "\n"
        else
            puts "+ <action> New a private app with github repo --- end" 
            return false
        end
    end

    def paste_a_git_repo(repo_address)
        make_sure_apps_page unless @driver.current_url =~ /.*apps.*/
        if new_app_btn_display?
            new_app_locator(:new_app_btn).click
        end
        new_app_locator(:paste_git_repo_input).send_keys(repo_address + "\n")
        return new_app_locator(:not_a_valid_github_url).text
    end

    def make_sure_apps_page
        @sign_in_page.make_sure_sign_in
        go_to_page :apps unless @driver.current_url =~ /.*apps.*/
    end

end
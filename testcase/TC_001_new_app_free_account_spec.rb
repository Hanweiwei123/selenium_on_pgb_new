#encoding: utf-8

require 'rspec'
require 'rubygems'

require_relative '../action/new_app_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/new_app_locator'
require_relative '../util/dialog_locator/header_footer_locator'

# This TC describes 
#   situations when try to create app(s) using free account(Adobe ID & Github-connected Adobe ID)
describe "TC_001: New app(s) with free account" do
    include NewAppLocator
    include ConfigParam
    include WebdriverHelper
    include HeaderFooterLocator

    before(:all) do
        puts "+ <TC_001> before all outer --- begin"
        init
        @order_of_it = WebdriverHelper::Counter.new
        @name_screenshot = "TC_001_IT_"
        @base_url = base_url
        @driver = driver
        @driver.manage.window.maximize
        puts "+ <TC_001> before all outer --- end"
    end

    # Try to delete all new-created apps 
    # to make sure it be a clean run the next time. 
    after(:all) do 
        puts "+ <TC_001> after all outer --- begin"
        begin 
            webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
            webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_connected_github][:id], $data[:user][$lang][:adobe_id_free_connected_github][:password]
        ensure
            @driver.quit
        end
        puts "+ <TC_001> after all outer --- end"
    end

    after(:each) do  # Take screenshot in case of failure
        @name_screenshot += @order_of_it.inc.to_s

        if example.exception != nil
            take_screenshot_with_name @name_screenshot
        end
    end

    # This context describes that 
    #   situations trying to create app(s) using Adobe ID(free). 
    context "--- with Adobe ID - free account" do 
        before(:all) do 
            puts "+ <TC_001> before all inside --- begin"
            @new_app_page = NewAppPage.new(
                    :driver => @driver, 
                    :base_url => @base_url,
                    :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password => $data[:user][$lang][:adobe_id_free_002][:password]})
            puts "+ <TC_001> before all inside --- end"
        end

        it "IT_001: verify the placeholder of 'paste .git repo' exists" do 
            puts "IT_" + @order_of_it.to_s
            if @new_app_page.new_app_btn_display? 
                new_app_locator(:new_app_btn).click
                puts "+ new_app_btn.click"
            end
            new_app_locator(:paste_git_repo_input).attribute('placeholder').should eql $data[:str][$lang][:PGB_paste_git_repo]
        end

        it "IT_002: verify the 'Connect your Github account' link exists" do  
            puts "IT_" + @order_of_it.to_s 
            new_app_locator(:connect_your_github_account_link).text.should eql $data[:str][$lang][:PGB_connect_your_github_account]
        end

        it "IT_003: got an warning message when submit an invalid .git address" do    
            puts "IT_" + @order_of_it.to_s
            @warning = @new_app_page.paste_a_git_repo("abcd")
            @warning.should eql $data[:str][$lang][:PGB_not_a_valid_github_url]
        end

        it "IT_004: the number of apps was 1 after creating an opensource app by pasting a .git" do  
            puts "IT_" + @order_of_it.to_s
            puts "+ before @new_app_page.new_public_app_with_repo"

            @new_app_page.new_public_app_with_repo

            app_count_after = @new_app_page.number_of_existing_apps
            first_app_id_after = @new_app_page.first_app_id
            puts "+ app_count_after: #{app_count_after}"
            puts "+ first_app_id_after: #{first_app_id_after}"
 
            app_count_after.should eql 1 
        end

        it "IT_005: the number of apps was not the same as before, after creating a private app by uploading a .zip file" do 
            puts "IT_" + @order_of_it.to_s
            @driver.navigate.refresh
            sleep 10

            app_count_before = @new_app_page.number_of_existing_apps
            first_app_id_before = @new_app_page.first_app_id
            puts "+ app_count_before: #{app_count_before}"
            puts "+ first_app_id_before: #{first_app_id_before}"

            @new_app_page.new_app_with_zip
          
            app_count_after = @new_app_page.number_of_existing_apps
            first_app_id_after = @new_app_page.first_app_id
            puts "+ app_count_after: #{app_count_after}"
            puts "+ first_app_id_after: #{first_app_id_after}"

            app_count_after.should_not eql @app_count_before 
            first_app_id_after.should_not eql @first_app_id_before
        end

        it "IT_006: trying to new another private app fails when there was already one private app"  do 
            puts "IT_" + @order_of_it.to_s
            # @driver.navigate.refresh
            sleep 10

            app_count_before = @new_app_page.number_of_existing_apps
            first_app_id_before = @new_app_page.first_app_id
            puts "+ app_count_before: #{app_count_before}"
            puts "+ first_app_id_before: #{first_app_id_before}"

            return_value = @new_app_page.new_app_with_zip 
           
            if (!return_value) 
                app_count_after = @new_app_page.number_of_existing_apps
                first_app_id_after = @new_app_page.first_app_id
                puts "+ app_count_after: #{app_count_after}"
                puts "+ first_app_id_after: #{first_app_id_after}"
                puts "+ You will not see me"
            end

            return_value.should eql false
        end

    end
=begin
    # This context describes that 
    #   situations trying to create app(s) using Adobe ID(free), which is connected Github
    context "--- with Adobe ID - free account - connected github" do 
        before(:all) do 
            puts "before all inside"
            @base_url = base_url
            @driver = browser
            @driver.manage.window.maximize
            @new_app_page = NewAppPage.new(@driver)
            @driver.get path_format_locale("/people/sign_in")
            @sign_in_page = SignInPage.new @driver, xpath: @data_xpath, url: @data_url, str: $data[:str], user: $data[:user]
            @sign_in_page.sign_in_with_adobe_id($data[:user][$lang][:adobe_id_free_connected_github][:id],
                                                $data[:user][$lang][:adobe_id_free_connected_github][:password])
            sleep 10
        end

        after(:all) do 
            @driver.quit
        end

        it "IT_007: the number of items of the dropdown list did not equal 0" do 
            puts "IT_" + @order_of_it.to_s
            if @new_app_page.new_app_btn_display? 
                new_app_btn.click
                puts "new_app_btn.click"
            end
            @driver.find_element(:xpath => "/html/body/section/div/div/div/form/div[2]/div/div/span[2]").click
            sleep 3
            li = @driver.find_elements(:xpath => "//*[@id='new-app']/form/div[2]/div[1]/div/ul/li")
            li_count = li.count
            puts "+li count: #{li_count}"
            li_count.should_not eql 0    
        end

        it "IT_008: check if the placeholder of 'find existing repo / paste .git repo' exists" do 
            puts "IT_" + @order_of_it.to_s
            if @new_app_page.new_app_btn_display? 
                new_app_btn.click
                puts "new_app_btn.click"
            end
            paste_git_repo_input.attribute('placeholder').to_s.should eql $data[:str][$lang][:PGB_find_existing_repo_or_paste_git_repo]
        end

        it "IT_009: got an errors when pasting a invalid .git address" do 
            puts "IT_" + @order_of_it.to_s
            if @new_app_page.new_app_btn_display? 
                new_app_btn.click
                puts "new_app_btn.click"
            end
            warning = @new_app_page.paste_a_git_repo("亜印gっをげwにwpw声wんw儀栄wペイ儀絵印rgる")
            warning.should eql $data[:str][$lang][:PGB_not_a_valid_github_url]
        end

        it "IT_010: there be an matched item from the dropdown list when entering some letters" do 
            puts "IT_" + @order_of_it.to_s
            if @new_app_page.new_app_btn_display? 
                new_app_btn.click
                puts "new_app_btn.click"
            end
            paste_git_repo_input.send_keys("sa")
            the_first_item = @driver.find_element(:xpath => "//*[@id='new-app']/form/div[2]/div[1]/div/ul/li")
            puts "The first matched item: #{the_first_item.text}"
            the_first_item.text.should eql $data[:str][$lang][:PGB_the_first_matched_item] 
        end

        it "IT_011: there be not any matched apps in the list when enter some specific letters in the placeholder" do 
            puts "IT_" + @order_of_it.to_s
            if @new_app_page.new_app_btn_display? 
                new_app_btn.click
                puts "new_app_btn.click"
            end
            paste_git_repo_input.clear
            paste_git_repo_input.send_keys("sss")
            the_first_item = @driver.find_element(:xpath => "//*[@id='new-app']/form/div[2]/div[1]/div/ul/li")
            puts "The first item: #{the_first_item.text}"
            the_first_item.text.should eql $data[:str][$lang][:PGB_no_match_item]
        end

        it "IT_012: the number of apps did not equal to 0 after creating app by selecting and clicking one from the matched items" do  
            puts "IT_" + @order_of_it.to_s
            if @new_app_page.new_app_btn_display? 
                new_app_btn.click
                puts "new_app_btn.click"
            end
            paste_git_repo_input.clear
            paste_git_repo_input.send_keys("start")
            the_first_item = @driver.find_element(:xpath => "//*[@id='new-app']/form/div[2]/div[1]/div/ul/li")
            the_first_item.click
            sleep 5

            wait_for_element_present(:xpath, @data_xpath[:sign_in_succ_page][:first_app_id])

            app_count_after = @new_app_page.number_of_existing_apps
            first_app_id_after = @new_app_page.first_app_id
            puts "+app_count_after: #{app_count_after}"
            puts "+first_app_id_after: #{first_app_id_after}"

            @app_count_after.should_not eql 0
        end
    end
=end
end

#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative "../action/new_app_page"
require_relative "../action/app_collaborators_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/new_app_locator"
require_relative "../util/dialog_locator/app_id_locator"

describe "TC_016: App Details #Collaborators" do
  include ConfigParam
  include WebdriverHelper
  include NewAppLocator
  include AppIdLocator

  before(:all) do 
    # sign in -> new app
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_016_IT_"
    @base_url = base_url
    @driver = driver
    @driver.manage.window.maximize
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")

    @new_app_page = NewAppPage.new :driver => @driver,
                                   :base_url =>@base_url ,
                                   :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password =>  $data[:user][$lang][:adobe_id_free_002][:password] }
    @new_app_page.new_app_with_zip
    sleep 15
    @app_id = @new_app_page.first_app_id
  end

  after(:all) do
      webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
      @driver.quit
  end

  after(:each) do  # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  context "---  App Details -> Collaborators  ---" do
    #it "should create an app successfully" do
    before(:all) do

      puts "created_app_id: #{@app_id}"
      @app_id.should =~ /\d/

      #@driver.navigate.refresh
      #sleep 5
      new_app_locator(:ready_to_build_btn).click
      sleep 15
      # new_app_locator(:clickable_app_title).click
      @driver.get @driver.current_url + "\/#{@app_id}\/builds"
      sleep 5

      @current_url = @driver.current_url
      puts "+<current_url> is #{@current_url}"
      @driver.current_url.should =~ /\S+\d\/builds/
      sleep 10
      collaborators(:tab).click
      collaborators(:add_collaborator_btn).click

      @app_collaborators_page=AppCollaboratorsPage.new :driver => @driver,
                                             :base_url =>@base_url ,
                                             :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password =>  $data[:user][$lang][:adobe_id_free_002][:password] }
      @invalid_email="something_of_no_email_format"
      @valid_email="phonegap_plugin@126.com" #"dil45216+test_free_007@adobetest.com"
    end
    
    it "IT_001: should add no collaborators using 'invalid email address'" do 

      # change_element_type_by_name :name => "email", :to_type => "text"
      # puts "+ <> after 'change_element_type_by_name'"
      @app_collaborators_page.add_a_collaborator(@invalid_email,'tester')
      
      @driver.current_url.should =~ /.*collaborators/

      number_of_collaborators = collaborators(:collaborators_block).find_elements(:tag_name => 'li').count
      number_of_collaborators.should eql 0
    end

    it "IT_002: should be one role_tester in the list" do
      sleep 5
      @app_collaborators_page.add_a_collaborator(@valid_email, 'tester')
      sleep 3
      @driver.current_url.should =~ /.*collaborators/

      number_of_collaborators = collaborators(:collaborators_block).find_elements(:tag_name => 'li').count
      number_of_collaborators.should eql 1

      collaborators(:first_collaborator_role).text.should eql $data[:str][$lang][:role_tester]
    end

    it "IT_003: should be changed to role_developer" do 

      @app_collaborators_page.edit_change_role(@valid_email,$data[:str][$lang][:role_tester])
      sleep 5

      @driver.current_url.should =~ /.*collaborators/

      number_of_collaborators = collaborators(:collaborators_block).find_elements(:tag_name => 'li').count
      number_of_collaborators.should eql 1

      collaborators(:first_collaborator_role).text.should eql $data[:str][$lang][:role_developer]
    end

    it "IT_004: the collaborator should be deleted" do

      @app_collaborators_page.delete_collaborator(@valid_email,$data[:str][$lang][:role_developer])
      sleep 5

      @driver.current_url.should =~ /\S+\d\/collaborators/

      number_of_collaborators = collaborators(:collaborators_block).find_elements(:tag_name => 'li').count
      number_of_collaborators.should eql 0
    end

  end
end

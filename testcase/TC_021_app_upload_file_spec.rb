#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative "../action/new_app_page"
require_relative "../action/app_collaborators_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/new_app_locator"
require_relative "../util/dialog_locator/app_id_locator"

#This TC description
describe 'TC_021: app update code' do

  include ConfigParam
  include WebdriverHelper
  include AppIdLocator
  include NewAppLocator

  before(:all) do
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_021_IT_"
    @base_url = base_url
    @driver = driver
    @driver.manage.window.maximize
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")
    @driver.manage.timeouts.implicit_wait = 30

    @new_app_page = NewAppPage.new :driver => @driver,
                                   :base_url =>@base_url ,
                                   :user => {:id => $data[:user][$lang][:adobe_id_free_001][:id], :password =>  $data[:user][$lang][:adobe_id_free_001][:password] }
  end

  after(:all) do
    begin
      webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_001][:id], $data[:user][$lang][:adobe_id_free_001][:password]
    ensure
      @driver.quit
    end
  end

  after(:each) do  # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  context "new private app with upload button with invalid file" do

    it "IT_001:check error msg localized when new app with a invalid filetype" do
      @new_app_page.new_app_with_zip("invalid_filetype");
      sleep 5
      new_app_locator(:error_alert_msg).text.should eql $data[:str][$lang][:app_id_update_code_invalid_filetype_msg]
    end

    it "IT_002:check error msg localized when new app with a large file" do
      @new_app_page.new_app_with_zip("invalid_large_file");
      sleep 5
      alert_msg_of_largefile=reorganization_string_resources(["15"],$data[:str][$lang][:app_id_update_code_invalid_large_file_msg])
      new_app_locator(:alert_msg_of_largefile).text.should eql alert_msg_of_largefile
    end

  end

  #description
  context "app head part upload update code" do

    #description
    before(:all) do
      @new_app_page.new_app_with_zip;  sleep 5
      @app_id = @new_app_page.first_app_id
      new_app_locator(:enable_debug_checkbox).click
      new_app_locator(:enable_hyd_checkbox).click
      new_app_locator(:ready_to_build_btn).click
      sleep 10
      @new_app_page.first_app_id
      nil.should_not eql new_app_locator(:debug_label)
      nil.should_not eql new_app_locator(:hyd_label)
      @driver.get @driver.current_url + "\/#{@app_id}\/builds" ;sleep 5
      @current_url = @driver.current_url
      puts "+<current_url> is #{@current_url}";
    end

    #description
    it 'IT_003: Those checkboxes should work well' do
      nil.should_not eql app_brief(:update_code_btn)
      nil.should_not eql app_brief(:rebuild_all_btn)
      nil.should_not eql app_brief(:debug_btn)
      nil.should_not eql app_brief(:hydration_btn)
    end

    it "IT_004:Those checkboxes should work well" do
      settings(:tab).click unless @driver.current_url =~ /.*settings.*/; sleep 5
      "true".should eql settings(:basic_settings_enable_debugging).attribute('checked').to_s
      "true".should eql settings(:basic_settings_enable_hydration).attribute('checked').to_s
    end

    it "IT_005:check error msg localized when update with a invalid filetype" do
      app_brief(:update_code_btn).click
      app_brief(:update_code_browser_btn).send_keys("C:\\assets\\application\\invalidfile\\LichuanIQEKey.p12")
      app_brief(:update_code_upload_btn).click;
      sleep 5
      #puts "+<error_alert_msg> is "+app_brief(:error_alert_msg).text
      app_brief(:error_alert_msg).text.should eql $data[:str][$lang][:app_id_update_code_invalid_filetype_msg]
    end
=begin
    it "IT_006:check error msg localized when update with a large file" do
      app_brief(:update_code_btn).click
      app_brief(:update_code_browser_btn).send_keys("C:\\assets\\application\\invalidfile\\index.html")
      #need Manually Click the button,the timeout error has not resolved
      begin
        #app_brief(:update_code_upload_btn).send_keys (:enter)
        app_brief(:update_code_upload_btn).click
      rescue Exception => ex
        puts "+ <Exception> the timeout error when click submit button to upload a large file"
      end
      
      sleep 500
      #puts "+<error_alert_msg> is "+app_brief(:error_alert_msg).text
      app_brief(:error_alert_msg).text.should eql $data[:str][$lang][:app_id_update_code_invalid_large_file_msg]
    end
=end
  end

  context "app Settings part upload update code" do

    before(:each) do
      settings(:tab).click unless @driver.current_url =~ /.*settings.*/; sleep 5
    end
=begin
    it "IT_007:check error msg localized when new app with a invalid filetype" do
      settings(:basic_source_code_browse_btn).send_keys("C:\\assets\\application\\invalidfile\\LichuanIQEKey.p12")
      settings(:basic_source_code_upload_btn).click;
      sleep 5
      return_value=is_element_present(:app_id_page,:error_alert_msg)
      puts "<error message>the erroe message displays "+return_value.to_s
      return_value.should eql true
      #nil.should_not eql app_brief(:error_alert_msg)
      #puts "--------------------"+app_brief(:error_alert_msg).text+"---------"
      #app_brief(:error_alert_msg).text.should eql $data[:str][$lang][:app_id_update_code_invalid_filetype_msg]
    end

    it "IT_008:check error msg localized when new app with a large file" do
      settings(:basic_source_code_browse_btn).send_keys("C:\\assets\\application\\invalidfile\\index.html")
      #need Manually Click the button,the timeout error has not resolved
       begin
        settings(:basic_source_code_upload_btn).send_keys (:enter)
        #settings(:basic_source_code_upload_btn).click;
      rescue Exception => ex
        puts "+ <Exception> the timeout error when click submit button to upload a large file"
      end
      
      sleep 100
      return_value=is_element_present(:app_id_page,:error_alert_msg)
      puts "<error message>the erroe message displays "+return_value.to_s
      return_value.should eql true
      #nil.should_not eql app_brief(:error_alert_msg)
      #puts "+<error_alert_msg> is "+app_brief(:error_alert_msg).text
      #app_brief(:error_alert_msg).text.should eql $data[:str][$lang][:app_id_update_code_invalid_large_file_msg]
    end
=end
    # it "IT_009: should delete the app successfully" do

    #   settings(:danger_zone_delete_app_btn).click
    #   @driver.switch_to.alert.accept; sleep 10
    #   @driver.navigate.refresh; sleep 5
    #   @driver.current_url.should =~ /.*apps$/
    # end

  end

  context "private zip app head part upload update code" do

    # before (:all) do
    #   @driver.get @base_url +"\/apps"
    #   @new_app_page.new_app_with_zip("zip");  sleep 10
    #   @app_id=@new_app_page.first_app_id
    #   new_app_locator(:ready_to_build_btn).click
    #   sleep 10
    #   @driver.get @driver.current_url + "\/#{@app_id}\/builds" ;sleep 5
    #   @current_url = @driver.current_url
    #   puts "+<current_url> is #{@current_url}";
    # end

    it "IT_009:check code has been updated" do
      @driver.navigate.refresh; sleep 5
      app_brief(:update_code_btn).click
      os = win_or_mac
      if os == 'mac'
        app_brief(:update_code_browser_btn).send_keys (File.expand_path("../assets/application/testzip.zip",__FILE__))
      elsif os == 'win'
        app_brief(:update_code_browser_btn).send_keys("C:\\assets\\application\\testzip.zip")
      else
        raise "Not supported Operating System."
      end
      app_brief(:update_code_upload_btn).click;sleep 10
      app_brief(:title).text.should include "test"
    end

  end
  
  context "private zip app head part upload update code" do

    before (:all) do
      settings(:tab).click unless @driver.current_url =~ /.*settings.*/; sleep 5
      settings(:danger_zone_delete_app_btn).click
      @driver.switch_to.alert.accept; sleep 10
      @driver.navigate.refresh; sleep 5
      @driver.current_url.should =~ /.*apps$/
    end

    it "IT_010:check error msg localized when new app with a large repo" do
      @new_app_page.new_public_app_with_repo("large_repo");
      sleep 5
      alert_msg_of_largefile=reorganization_string_resources(["15"],$data[:str][$lang][:new_app_with_invalid_large_file_msg])
      new_app_locator(:alert_msg_of_largefile).text.should eql alert_msg_of_largefile
    end
    
  end

end

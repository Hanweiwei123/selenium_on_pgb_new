#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative "../action/new_app_page"
require_relative "../action/app_collaborators_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/new_app_locator"
require_relative "../util/dialog_locator/app_id_locator"

describe "TC_017: App Details #Collaborators" do
  include ConfigParam
  include WebdriverHelper
  include NewAppLocator
  include AppIdLocator

  before(:all) do
    # sign in -> new app
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_017_IT_"
    @base_url = base_url
    @driver = driver
    @driver.manage.window.maximize
    @driver.manage.timeouts.implicit_wait = 30
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")

    @new_app_page = NewAppPage.new :driver => @driver,
                                   :base_url =>@base_url ,
                                   :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password => $data[:user][$lang][:adobe_id_free_002][:password] }
    #@new_app_page.new_app_with_zip
    @new_app_page.new_public_app_with_repo
    # sleep 15
    @app_id = @new_app_page.first_app_id;
  end

  after(:all) do
      webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
      @driver.quit
  end

  after(:each) do # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  context "--- App ID -> Settings(Basic) ---" do
    #it "should create an app successfully" do
    before(:all) do
      @driver.navigate.refresh; sleep 10
      new_app_locator(:ready_to_build_btn).click;
      @driver.navigate.refresh; sleep 10
      @driver.get @driver.current_url + "\/#{@app_id}\/builds"
      sleep 5

      @current_url = @driver.current_url
      puts "+<current_url> is #{@current_url}"

      @driver.current_url.should =~ /\S+\d\/builds/
      sleep 10
      settings(:tab).click unless @driver.current_url =~ /.*settings.*/; sleep 5
    end

    it "IT_001: the h1 title should be localized" do
      
      settings(:basic_title).text.should eql $data[:str][$lang][:app_id_settings_basic_title]
    end
    
    it "IT_002:Pull a git repo should work well " do
      settings(:basic_repo_url_input).attribute('value').should eql $data[:app][:new_app][:by_repo]
      settings(:basic_pull_btn).click
      app_brief(:notice_alert_msg).text.should eql $data[:str][$lang][:app_id_update_notice]
    end

    it "IT_003: Those checkboxes should work well " do

      settings(:tab).click unless @driver.current_url =~ /.*settings.*/;
      let_it_checked settings(:basic_settings_enable_debugging)
      let_it_checked settings(:basic_settings_enable_hydration)
      let_it_checked settings(:basic_settigns_only_approved_colla)
      settings(:basic_save_btn).click; sleep 5

      @driver.navigate.refresh; sleep 5
      settings(:tab).click unless @driver.current_url =~ /.*settings.*/;

      "true".should eql settings(:basic_settings_enable_debugging).attribute('checked').to_s
      "true".should eql settings(:basic_settings_enable_hydration).attribute('checked').to_s
      "true".should eql settings(:basic_settigns_only_approved_colla).attribute('checked').to_s
      nil.should_not eql app_brief(:debug_btn)
      nil.should_not eql app_brief(:hydration_btn)
    end

  end

  context "--- App ID -> Settings(Configuration) ---" do

    it "IT_004: the title should be localized" do

      settings(:config_title).text.to_s.should eql $data[:str][$lang][:app_id_settings_configuration_title]
    end

    it "IT_005: those input box should work well" do

      os = win_or_mac
      if os == 'mac'
        settings(:config_app_icon_file).send_keys (File.expand_path("../assets/application/icon.jpg",__FILE__))
      elsif os == 'win'
        settings(:config_app_icon_file).send_keys "C:\\assets\\application\\icon.jpg"
      else
        raise "Not supported Operating System."
      end
      fill_in settings(:config_app_title), :with => $data[:app][:app_detail][:title]
      fill_in settings(:config_app_package), :with => $data[:app][:app_detail][:package]
      fill_in settings(:config_app_version), :with => $data[:app][:app_detail][:version]
      settings(:config_app_phonegap_version).find_elements(:tag_name => "option").each do |opt|
        if opt.attribute('value').to_s == "2.7.0"
          opt.click
          break
        end
      end
      fill_in settings(:config_app_desc), :with => $data[:app][:app_detail][:desc]
      settings(:config_save_btn).click

      @driver.navigate.refresh; sleep 5
      settings(:tab).click unless @driver.current_url =~ /.*settings.*/;
      settings(:config_app_icon_img).attribute('src').should include $data[:app][:app_detail][:img]
      settings(:config_app_package).attribute('value').should eql $data[:app][:app_detail][:package]
      settings(:config_app_version).attribute('value').should eql $data[:app][:app_detail][:version]
      settings(:config_app_phonegap_version).find_elements(:tag_name => "option").each do |opt|
        if opt.attribute('value').to_s == "2.7.0"
          expect(opt.attribute('checked').to_s).to eq("true")
          break
        end
      end
      settings(:config_app_desc).attribute('value').should eql $data[:app][:app_detail][:desc]
      settings(:config_app_title).attribute('value').should eql $data[:app][:app_detail][:title]
    end

  end

  context "--- App ID -> Settings(Danger Zone) ---" do

    it "IT_006: the title should be localized" do

      settings(:danger_zone_title).text.to_s.should eql $data[:str][$lang][:app_id_settings_danger_zone_title]
    end

    it "IT_007: should delete the app successfully" do

      settings(:danger_zone_delete_app_btn).click
      @driver.switch_to.alert.accept; sleep 10
      @driver.navigate.refresh; sleep 5
      @driver.current_url.should =~ /.*apps$/
    end

  end

end

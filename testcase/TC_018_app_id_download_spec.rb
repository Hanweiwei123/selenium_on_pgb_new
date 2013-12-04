#encoding: utf-8

require 'timeout'
require 'rubygems'
require 'rspec'
require "rautomation"

require_relative "../action/new_app_page"
require_relative "../action/app_collaborators_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/new_app_locator"
require_relative "../util/dialog_locator/app_id_locator"

describe "TC_018: App Id #Downloads" do
  include ConfigParam
  include WebdriverHelper
  include NewAppLocator
  include AppIdLocator

  before(:all) do
    # sign in -> new app
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_018_IT_"
    @base_url = base_url
    #@base_url = "https://buildstage.phonegap.com"
    #@base_url = "https://build.phonegap.com"
    @driver = driver
    @available_downloads = []
    @unavailable_downloads = []
    @pending_buildings = []
    @download_dir = Dir.home + "/Downloads"
    @driver.manage.timeouts.implicit_wait = 30
    @driver.manage.window.maximize
    @driver.execute_script("window.resizeTo(screen.width,screen.height)")

    @new_app_page = NewAppPage.new :driver => @driver,
                                   :base_url => @base_url,
                                   #:user => {:id => $data[:user][$lang][:adobe_id_free_003_build][:id], :password => $data[:user][$lang][:adobe_id_free_003_build][:password] }
                                   #:user => {:id => "shuai.yan@dilatoit.com", :password => "yanshuai110"}
                                   :user => {:id => $data[:user][$lang][:adobe_id_free_002][:id], :password => $data[:user][$lang][:adobe_id_free_002][:password]}
    @new_app_page.new_app_with_zip
    sleep 15
    @app_id = @new_app_page.first_app_id;
  end

  after(:all) do
    webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_002][:id], $data[:user][$lang][:adobe_id_free_002][:password]
    #webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_003_build][:id], $data[:user][$lang][:adobe_id_free_003_build][:password]
    #webhelper_delete_all_apps "shuai.yan@dilatoit.com", "yanshuai110"
    @driver.quit
  end

  after(:each) do # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s
    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  context "---  App ID -> Install(Download)  ---" do
    #it "should create an app successfully" do
    before(:all) do
      # @driver.navigate.refresh;  sleep 10
      new_app_locator(:ready_to_build_btn).click; sleep 10
      # @driver.navigate.refresh;  sleep 5
      @driver.get @driver.current_url + "\/#{@app_id}\/builds"
      sleep 5
      puts "+<current_url> is #{@driver.current_url}"

      $data[:platform].each do |platform|
        begin
          timeout(120) {
            while $data[:str][$lang][:builds_action_pending] == builds(:"#{platform}_action").text do
              @driver.navigate.refresh; sleep 10
              puts "+ action: " + builds(:"#{platform}_action").text
            end
            if builds(:"#{platform}_action").text != $data[:str][$lang][:builds_action_error]
              @available_downloads << platform
            else
              @unavailable_downloads << platform
            end
            break
          }
        rescue Exception => ex
          @pending_buildings << platform
        end
      end

      puts "--- TC_018 Available download app were: ---"
      @available_downloads.each { |ptf| p ptf }
      puts "-----------------------------------------------"
      puts "--- TC_018 Not available download app were: ---"
      @unavailable_downloads.each { |ptf| p ptf }
      puts "-----------------------------------------------"
      puts "--- TC_018 Pending building app were: ---"
      @pending_buildings.each { |ptf| p ptf }
      puts "-----------------------------------------------"

    end

    it "The page should direct to 'install' page" do

      app_brief(:install_btn).click; sleep 5
      @driver.current_url.should =~ /.*install$/
    end

    it "IT_001: should not download the >>iOS<< app successfully" do
      true.should eql @unavailable_downloads.include?("ios")
    end

    it "ITC_002: should download the >>Android<< app successfully " do

      if @available_downloads.include?('android')
        install_btn('android').click; sleep 10
        download_with_different_browser
        sleep 10
        Dir["#{@download_dir}/*.apk"].count.should > 0
        system("rm #{@download_dir}/*.apk")
      else
        puts "+ <result> Android app was not available"
      end
    end

    it "ITC_003: should download the >>BlackBerry<< app successfully" do

      if @available_downloads.include?('blackberry')
        if :chrome == ENV['PGBBROWSER'].to_sym
          @driver.get @base_url + "\/apps\/#{@app_id}\/builds"; sleep 5
          @driver.get @base_url + "\/apps\/#{@app_id}\/install"; sleep 5
        end
        install_btn('blackberry').click; sleep 10
        download_with_different_browser
        sleep 10
        Dir["#{@download_dir}/*.jad"].count.should > 0
        system("rm #{@download_dir}/*.jad")
      else
        puts "+ <result> BlackBerry app was not available"
      end
    end

    it "IT_004: Should download the >>Winphone<< app successfully" do

      if @available_downloads.include?('winphone')
        if :chrome == ENV['PGBBROWSER'].to_sym
          @driver.get @base_url + "\/apps\/#{@app_id}\/builds"; sleep 5
          @driver.get @base_url + "\/apps\/#{@app_id}\/install"; sleep 5
        end
        install_btn('winphone').click; sleep 10
        download_with_different_browser
        sleep 10
        Dir["#{@download_dir}/*.xap"].count.should > 0
        system("rm #{@download_dir}/*.xap")
      else
        puts "+ <result> WinPhone app was not available"
      end
    end

    it "IT_005: should download the >>WebOS<< app successfully" do

      if @available_downloads.include?('webos')
        if :chrome == ENV['PGBBROWSER'].to_sym
          @driver.get @base_url + "\/apps\/#{@app_id}\/builds"; sleep 5
          @driver.get @base_url + "\/apps\/#{@app_id}\/install"; sleep 5
        end
        install_btn('webos').click; sleep 10
        download_with_different_browser
        sleep 10
        Dir["#{@download_dir}/*.ipk*"].count.should > 0
        system("rm #{@download_dir}/*.ipk*")
      else
        puts "+ <result> WebOS app was not available"
      end
    end

    it "IT_006: should download the >>Symbian<< app successfully " do

      if @available_downloads.include?('symbian')
        if :chrome == ENV['PGBBROWSER'].to_sym
          @driver.get @base_url + "\/apps\/#{@app_id}\/builds"; sleep 5
          @driver.get @base_url + "\/apps\/#{@app_id}\/install"; sleep 5
        end
        install_btn('symbian').click; sleep 10
        download_with_different_browser
        sleep 10
        Dir["#{@download_dir}/*.wgz"].count.should > 0
        system("rm #{@download_dir}/*.wgz")
      else
        puts "+ <result> Symbian app was not available"
      end
    end

  end

end

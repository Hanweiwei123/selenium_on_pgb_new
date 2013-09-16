#encoding: utf-8

require 'rubygems'
require 'yaml'
require 'selenium-webdriver'

module ConfigParam
    
    def base_url
        base_url = "http://loc.build.phonegap.com" 
        puts "+ <data>/base_env.rb base_url = #{base_url}"
        return base_url
    end

    def driver()     
        browser = ENV['PGBBROWSER'].to_sym
        if browser == :chrome
            profile = Selenium::WebDriver::Chrome::Profile.new
            profile['intl.accept_languages'] = $lang.to_s
            profile['download.prompt_for_download'] = false
            profile['download.default_directory'] = "#{Dir.home}/Downloads/"
            puts "+ <data>/base_env.rb browser = chrome"
            Selenium::WebDriver.for :chrome  # :profile => profile
        elsif browser == :firefox
            profile = Selenium::WebDriver::Firefox::Profile.new
            profile['intl.accept_languages'] = $lang.to_s
            profile['browser.download.folderList'] = 2
            profile['browser.download.dir'] = "#{Dir.home}/Downloads/"
            profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/xap'
            puts "+ <data>/base_env.rb browser = firefox"
            Selenium::WebDriver.for :firefox , :profile => profile
        else
            Selenium::WebDriver.for browser 
        end
    end 

    # Helps to get the global variable value
    # They are used everywhere later.  
    def init
      $config = {}
      $config[:base_url] = "http://loc.build.phonegap.com"
      $config[:lang] = ENV['PGBLANG'].to_sym

      $lang = $config[:lang]
      $base_url = $config[:base_url]

      $data = {}
      $data[:xpath] = YAML::load(File.read(File.expand_path("../../data/data_xpath.yml",__FILE__)))
      $data[:user] = YAML::load(File.read(File.expand_path("../../data/data_user.yml",__FILE__)))
      $data[:str] = YAML::load(File.read(File.expand_path("../../data/data_str.yml",__FILE__)))
      $data[:app] = YAML::load(File.read(File.expand_path("../../data/data_app.yml",__FILE__)))
      $data[:url] = YAML::load(File.read(File.expand_path("../../data/data_url.yml",__FILE__)))
      $data[:signing_key] = YAML::load(File.read(File.expand_path("../../data/data_signing_key.yml",__FILE__)))
      $data[:plugin] = YAML::load(File.read(File.expand_path("../../data/data_plugin.yml",__FILE__)))
      $data[:platform] = ['ios', 'android', 'blackberry', 'winphone', 'webos', 'symbian']
    end 

    def create_folder_unless_exist(folder_name)
        if(File.directory?(folder_name)) 
            puts "+ <lib> folder #{folder_name} --- exists"
        else
            Dir.mkdir(folder_name) 
            puts "+ <lib> folder #{folder_name} --- created"
        end
    end 

    # Initialization work
    # It is to recreate folders, which will be used to store log file and screenshot files. 
    def initialize_params(name_subdir)
        puts "+ <lib> initialize_params begin"

        # Then to create the structure
        name_sub_dir = name_subdir
        create_folder_unless_exist("./auto_results")
        create_folder_unless_exist("./auto_results/#{name_sub_dir}")
        create_folder_unless_exist("./auto_results/#{name_sub_dir}/screenshots")

        puts "+ <lib> initialize_params end"
    end

end  

#encoding: utf-8 

module SettingsPage

    # include SettingsDialog

    class UnableToLoadPage < StandardError; end
    class SubclassResponsibility < StandardError; end

    def change_app_infor(title, package, version, config, desc)
        load unless loaded?

        unless loaded?
              raise UnableToLoadPage, unable_to_load_message
        end
        
        enter_app_title(title)
        enter_app_package(package)
        enter_app_version(version)
        enter_app_configuration(config)
        enter_app_description(desc)

        submit
    end

    def enter_app_title(title)
        @field = @driver.find_element(:xpath => @data_xpath[:app_detail_page][:settings][:configuration][:title])
        clear_and_type(@field, title)
    end

    def enter_app_package(package)
        @field = @driver.find_element(:xpath => @data_xpath[:app_detail_page][:settings][:configuration][:package])
        clear_and_type(@field, package)
    end

    def enter_app_version(version)
        @field = @driver.find_element(:xpath => @data_xpath[:app_detail_page][:settings][:configuration][:version])
        clear_and_type(@field, version)
    end

    def enter_app_configuration(config)    
        @field = @driver.find_element(:xpath => @data_xpath[:app_detail_page][:settings][:configuration][:configuration])
        clear_and_type(@field, config)
    end

    def enter_app_description(desc)
       @field = @driver.find_element(:xpath => @data_xpath[:app_detail_page][:settings][:configuration][:description])
       clear_and_type(@field, desc)
    end

    def submit 
       @driver.find_element(:xpath => @data_xpath[:app_detail_page][:settings][:configuration][:save]).click
       EditIssue.new(@driver)
    end

    def load
        @driver.get "https://buildstage.phonegap.com/apps/_ID/settings"
    end

    def loaded?
        @url = @driver.current_url
        true 
    end

    def unable_to_load_message
        "could not load #{self.class.name}"
      end

    # private
    def clear_and_type(field, text)
       field.clear
       field.send_keys(text)
    end
end

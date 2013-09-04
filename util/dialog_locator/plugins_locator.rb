#encoding: utf-8

require_relative "../webdriver_helper"

module PluginsLocator
    include WebdriverHelper

    def plugin_locator(str)
        highlight_and_return @driver.find_element(:xpath => $data[:xpath][:plugins_page][str]) 
    end
    
end

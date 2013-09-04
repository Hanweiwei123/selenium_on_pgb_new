#encoding: utf-8
require_relative "../webdriver_helper"

module SignInLocator
    include WebdriverHelper

    def sign_in_locator(element)
      highlight_and_return @driver.find_element(:xpath => $data[:xpath][:sign_in_page][element]) 
    end
    
end

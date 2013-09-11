#encoding: utf-8

require_relative "../webdriver_helper"

module NewAppLocator
    include WebdriverHelper

    def new_app_locator(arg)
        @driver.find_element(:xpath => $data[:xpath][:new_app_page][arg])
    end

end
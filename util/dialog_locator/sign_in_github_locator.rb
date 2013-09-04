#encoding: utf-8

require_relative "../webdriver_helper"

module SignInGithubLocator
    include WebdriverHelper

    def sign_in_github_locator(str)
      @driver.find_element(:xpath => $data[:xpath][:sign_in_github_page][str]) 
    end
end
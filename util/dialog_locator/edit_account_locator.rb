#encoding: utf-8

require_relative "../webdriver_helper"

module EditAccountLocator
	include WebdriverHelper

# --- Account Details Tab
	def ea_account_details(arg)
		@driver.find_element(:xpath => $data[:xpath][:edit_account_page][:acntdetails][arg])
	end


# --- Private code hosting Tab
	def ea_private_ch(arg)
		highlight_and_return @driver.find_element(:xpath => $data[:xpath][:edit_account_page][:pch][arg])
	end


# --- Signing Keys Tab
	def ea_signing_keys(arg)
		highlight_and_return @driver.find_element(:xpath => $data[:xpath][:edit_account_page][:sks][arg])
	end	


end
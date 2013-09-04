#encoding: utf-8

# This module is all about 
# filling form about billing information. 

module AnywareContainer

	def fill_Payment_Card(
		holdername = "Taro Yamada", 
		cardnumber = "4111 1111 1111 1111",
		securitycode = "111",
		expiration_m = "5",
		expiration_y = "2014"
		)

		@driver.switch_to.frame(0)
		puts "switch_to.frame(0)"
		enter_CardHolder holdername
		enter_CardNumber1 cardnumber 
		enter_CardNumber2 securitycode
		enter_ExpirationDateMonth expiration_m
		enter_ExpirationDateYear expiration_y
	end

	def fill_Billing_Address(
		lname = "Taro",
		fname = "Yamada",
		lnameP = "AAAAA",
		fnameP = "BBBBB",
		zip1 = "141",
		zip2 = "0032",
		state = "東京都",
		city = "品川区",
		addressone = "1丁目11番地2号",
		phone = "03-5040-2408"
		)
		
		enter_BillingLastName lname
		enter_BillingFirstName fname
		enter_BillingLastNamePronounce lnameP
		enter_BillingFirstNamePronounce fnameP
		enter_BillingZip1 zip1
		enter_BillingZip2 zip2
		enter_BillingState state
		enter_BillingCity city
		enter_BillingAddressOne addressone
		enter_BillingPhone phone
		puts "switch_to.default_content"
		@driver.switch_to.default_content
	end


	def enter_CardHolder(arg) 
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:CardHolder]).send_keys(arg)
	end
	def enter_CardNumber1(arg)
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:CardNumber1]).send_keys(arg)
	end
	def enter_CardNumber2(arg)
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:CardNumber2]).send_keys(arg)
	end
	def enter_ExpirationDateMonth(arg)
		select = @driver.find_element(:xpath => @data_xpath[:anywareContainer][:ExpirationDateMonth])
		options = select.find_elements(:tag_name => "option")
		options.each do |op|
			if(op.attribute("value") == arg)
				op.click
				break
			end
		end
	end
	def enter_ExpirationDateYear(arg)
		select = @driver.find_element(:xpath => @data_xpath[:anywareContainer][:ExpirationDateYear])
		options = select.find_elements(:tag_name => "option")
		options.each do |op|
			if(op.attribute("value") == arg)
				op.click
				break
			end
		end
	end
	def enter_BillingLastName(arg = "Taro")
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:BillingLastName]).send_keys(arg)
	end
	def enter_BillingFirstName(arg = "Yamada")
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:BillingFirstName]).send_keys(arg)
	end
	def enter_BillingLastNamePronounce(arg = "AAAAA")
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:BillingLastNamePronounce]).send_keys(arg)
	end
	def enter_BillingFirstNamePronounce(arg = "BBBBB")
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:BillingFirstNamePronounce]).send_keys(arg)
	end
	def enter_BillingZip1(arg = "141")
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:BillingZip1]).send_keys(arg)
	end
	def enter_BillingZip2(arg = "0032")
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:BillingZip2]).send_keys(arg)
	end
	def enter_BillingState(arg = "東京都")
		select = @driver.find_element(:xpath => @data_xpath[:anywareContainer][:BillingState])
		options = select.find_elements(:tag_name => "option")
		options.each do |op|
			if(op.text == arg)
				op.click
				break
			end
		end
	end
	def enter_BillingCity(arg = "品川区")
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:BillingCity]).send_keys(arg)
	end
	def enter_BillingAddressOne(arg = "1丁目11番地2号")
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:BillingAddressOne]).send_keys(arg)
	end
	def enter_BillingPhone(arg = "03-5040-2408")
		@driver.find_element(:xpath => @data_xpath[:anywareContainer][:BillingPhone]).send_keys(arg)
	end

end
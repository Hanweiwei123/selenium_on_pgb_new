#encoding: utf-8

require 'rubygems'
require 'rspec'

require_relative '../action/new_app_page'
require_relative '../util/config_param'
require_relative '../util/webdriver_helper'
require_relative '../util/dialog_locator/new_app_locator'
require_relative '../util/dialog_locator/app_id_locator'

describe "TC_019: App Id #Abuse " do
  include ConfigParam
  include WebdriverHelper
  include NewAppLocator
  include AppIdLocator

  before(:all) do
    puts "+ <TC_001> before all outer --- begin"
    init
    @order_of_it = WebdriverHelper::Counter.new
    @name_screenshot = "TC_019_IT_"
    #@base_url = base_url
    @base_url = "https://build.phonegap.com"
    @driver = driver
    @driver.manage.window.maximize
    @driver.manage.timeouts.implicit_wait = 30

    @new_app_page = NewAppPage.new(
        :driver => @driver,
        :base_url => @base_url,
        :user => {:id => $data[:user][$lang][:adobe_id_free_003_build][:id], :password => $data[:user][$lang][:adobe_id_free_003_build][:password]})
    @new_app_page.new_public_app_with_repo; sleep 5
    @driver.navigate.refresh; sleep 5
    @app_id = @new_app_page.first_app_id;
    puts "+ <first_app_id> is #{@app_id}"
    new_app_locator(:ready_to_build_btn).click; sleep 5
    new_app_locator(:public_page_btn).click; sleep 3
    puts "+ <TC_019> before all outer --- end"
  end

  after(:all) do
    puts "+ <TC_019> after all outer --- begin"
    begin
      webhelper_delete_all_apps $data[:user][$lang][:adobe_id_free_003_build][:id], $data[:user][$lang][:adobe_id_free_003_build][:password]
    ensure
      @driver.quit
    end
    puts "+ <TC_019> after all outer --- end"
  end

  after(:each) do # Take screenshot in case of failure
    @name_screenshot += @order_of_it.inc.to_s

    if example.exception != nil
      take_screenshot_with_name @name_screenshot
    end
  end

  context "Check strings of 'Abuse' tab" do

    before(:all) do
      abuse(:report_abuse_link).click;
    end

    it "IT_001: should match to localized strings: >> report_abuse_title <<" do
      abuse(:report_abuse_title).text.should eql   $data[:str][$lang][:app_id_abuse_report_title]
    end

    it "IT_002: should match to localized strings: >> email_address_label <<" do
      abuse(:email_address_label).text.should eql   $data[:str][$lang][:app_id_abuse_email_label]
    end

    it "IT_003: should match to localized strings: >> name_label <<" do
      abuse(:name_label).text.should eql   $data[:str][$lang][:app_id_abuse_name_label]
    end

    it "IT_004: should match to localized strings: >> why_label <<" do
      abuse(:why_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_label]
    end

    it "IT_005: should match to localized strings: >> why_Defamation_label <<" do
      abuse(:why_Defamation_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_Defamation_label]
    end

    it "IT_006: should match to localized strings: >> why_SEC_label <<" do
      abuse(:why_SEC_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_SEC_label]
    end

    it "IT_007: should match to localized strings: >> why_TI_label <<" do
      abuse(:why_TI_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_TI_label]
    end

    it "IT_008: should match to localized strings: >> why_OC_label <<" do
      abuse(:why_OC_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_OC_label]
    end

    it "IT_009: should match to localized strings: >> why_RHC_label <<" do
      abuse(:why_RHC_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_RHC_label]
    end

    it "IT_010: should match to localized strings: >> why_Other_label <<" do
      abuse(:why_Other_label).text.should eql   $data[:str][$lang][:app_id_abuse_why_Other_label]
    end

    it "IT_011: should match to localized strings: >> description_label <<" do
      abuse(:description_label).text.should eql   $data[:str][$lang][:app_id_abuse_description_label]
    end

    it "IT_012: should match to localized strings: >> copyright_violation_label <<" do
      abuse(:copyright_violation_label).text.should eql   $data[:str][$lang][:app_id_abuse_copyright_violation_label]
    end

    it "IT_013: should match to link of copyright_violation" do
      puts "+<check> copyright_violation_link href is " + abuse(:copyright_violation_link).attribute("href")
      abuse(:copyright_violation_link).attribute("href").should include "/misc/terms.html"
    end

  end

  context "Check abuse report button" do

    before(:each) do
      abuse(:report_abuse_link).click;
    end

    it "IT_014: check cancel button" do
      abuse(:cancel_btn).click;
      puts "+<check> report_abuse_form style is " + abuse(:report_abuse_form).attribute("style")
      abuse(:report_abuse_form).attribute("style").should include "display: none"
    end

    it "IT_015: check report button"do
      puts "+<check> email_address_default_value is " + abuse(:email_address_input).attribute("value")
      abuse(:email_address_input).attribute("value").should eql $data[:user][$lang][:adobe_id_free_003_build][:id]
      abuse(:email_address_input).clear
      abuse(:email_address_input).send_keys($data[:user][$lang][:adobe_id_free_003_build][:id])
      abuse(:name_input).clear
      abuse(:name_input).send_keys "name"
      abuse(:why_Defamation_input).click;
      abuse(:why_SEC_input).click;
      abuse(:why_TI_input).click;
      abuse(:why_OC_input).click;
      abuse(:why_RHC_input).click;
      abuse(:why_Other_input).click;
      abuse(:why_Defamation_input).click;
      abuse(:description_input).clear
      abuse(:description_input).send_keys "description"
      abuse(:report_btn).click; sleep 5
      abuse(:report_success_label).text.should eql $data[:str][$lang][:app_id_abuse_report_success_title]
    end

  end


end

#encoding: utf-8

require_relative "../action/sign_in_page"
require_relative "../util/config_param"
require_relative "../util/webdriver_helper"
require_relative "../util/dialog_locator/app_id_locator"

class AppCollaboratorsPage
  include AppIdLocator
  include WebdriverHelper
  include AppIdLocator

  def initialize(options = {})
    @os = win_or_mac
    raise "Must pass a hash containing ':user'" if not options.is_a?(Hash) or not options.has_key?(:user)
    raise "Must pass a hash containing ':driver'" if not options.is_a?(Hash) or not options.has_key?(:driver)
    if not options.has_key?(:base_url)
      @base_url = $config[:base_url]
    else
      @base_url = options.delete(:base_url)
    end

    @driver = options.delete(:driver)
    @data_user = options.delete(:user)
    @user_id = @data_user.delete(:id)
    @user_password = @data_user.delete(:password)

    @sign_in_page = SignInPage.new :driver => @driver, :base_url =>@base_url , :user => {:id => @user_id.to_s, :password => @user_password.to_s }
  end


  #Tester=reader Developer=writer
  def add_a_collaborator(email, role)
    collaborators(:email_address_input).clear
    collaborators(:email_address_input).send_keys email
    if ['test', 'tester', 'reader'].include?(role.downcase)
      collaborators(:role_reader_radio_btn).click
    elsif ['writer', 'dev','developer'].include?(role.downcase)
      collaborators(:role_writer_radio_btn).click
    else
      puts "please check the role of collaborator ."
    end
    collaborators(:submit_btn).click
  end

  def edit_change_role(email, role)
    #                             //ul/li[h3[contains(text(),"phonegap_plugin@126.com")]/small[contains(text(),"Testeur")]]/div/a
    @driver.find_element(:xpath => "//ul/li[h3[contains(text(),'#{email}')]/small[contains(text(),'#{role}')]]/div/a").click
    if ['test', 'tester', 'reader'].include?(role.downcase)
      @driver.find_element(:xpath => "//ul/li[h3[contains(text(),'#{email}')]/small[contains(text(),'#{role}')]]/form/label[2]/input").click
    elsif ['writer', 'dev','developer'].include?(role.downcase)
      @driver.find_element(:xpath => "//ul/li[h3[contains(text(),'#{email}')]/small[contains(text(),'#{role}')]]/form/label/input").click
    else
      puts "please check the role of collaborator ."
    end
    @driver.find_element(:xpath => "//ul/li[h3[contains(text(),'#{email}')]/small[contains(text(),'#{role}')]]/form/footer/button[2]").click
    sleep 5
  end

  def delete_collaborator(email ,role)
    sleep 5
    @driver.find_element(:xpath => "//ul/li[h3[contains(text(),'#{email}')]/small[contains(text(),'#{role}')]]/div/a[2]").click
    @driver.find_element(:xpath => "//ul/li[h3[contains(text(),'#{email}')]/small[contains(text(),'#{role}')]]/form/button[2]").click
    sleep 5
  end


end
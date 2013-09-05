#encoding: utf-8

require 'rest_client'

module WebdriverHelper

    def fill_in(locator, options={})
        raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
        with = options.delete(:with)
        locator.clear
        locator.send_keys(with)
    end

    def let_it_checked(element)
        raise "This element is not of checkbox type" unless element.attribute('type').to_s == 'checkbox'   # type="checkbox"
        element.click if "" == element.attribute('checked').to_s
    end

    # highlight-element suggested by https://gist.github.com/marciomazza/3086536
    def highlight_and_return field
      highlight field
      return field
    end

    def highlight(element, ancestors=0)
        @driver.execute_script("hlt = function(c) { c.style.border='solid 1px rgb(255, 16, 16)'; }; return hlt(arguments[0]);", element)
        parents = ""
        red = 255

        ancestors.times do
            parents << ".parentNode"
            red -= (12*8 / ancestors)
            @driver.execute_script("hlt = function(c) { c#{parents}.style.border='solid 1px rgb(#{red}, 0, 0)'; }; return hlt(arguments[0]);", element)
        end
        sleep 1
    end

    # detect operating system (win or mac only right now)
    def win_or_mac
        os = RUBY_PLATFORM
        if os.include? 'darwin'
            puts "+ <lib><webdriver_helper> OS: Mac OSX"
            return 'mac'
        elsif os.include? 'mingw32'
            puts "+ <lib><webdriver_helper> OS: Windows"
            return 'win'
        else
            puts "+ <lib><webdriver_helper> Sorry, we do not support your Operating-System right now"
        end
    end
     
    def take_screenshot_with_name name
        browser = ENV['PGBBROWSER'] 
        lang = ENV['PGBLANG'] 
        if win_or_mac == 'win'
            dir = Dir.pwd + "/auto_results/#{lang}_#{browser}/screenshots/#{name}.png"
            puts "+ <lib><webdriver_helper> save screenshots to #{dir}"
        elsif win_or_mac == 'mac'
            dir = "./auto_results/#{lang}_#{browser}/screenshots/#{name}.png"
            puts "+ <lib><webdriver_helper> save screenshots to #{dir}"
        else
            puts "+ <lib><webdriver_helper> Sorry, we do not support your Operating-System right now"
        end
        @driver.save_screenshot "#{dir}" 
    end

    # Helper Utility
    # Helps to delete all apps via API
    def webhelper_delete_all_apps (username, password, base_url = @base_url)
        private_resource = RestClient::Resource.new base_url + "/api/v1/apps" , {:user => username , :password => password , :timeout => 30}
        response = private_resource.get :accept => :json
        json =  JSON.parse(response)
        json['apps'].each do |i|
            url = base_url + i['link']
            private_resource = RestClient::Resource.new url , {:user => username , :password => password , :timeout => 30}
            response = private_resource.delete 
            puts response.to_str
        end
    end

    # Helper Utility
    # Helps to delete all signing-keys via API. 
    def webhelper_delete_all_signing_keys(username, password, base_url = @base_url)
        private_resource = RestClient::Resource.new base_url + "/api/v1/keys", {:user => username , :password => password , :timeout => 30}
        response = private_resource.get :accept => :json
        json =  JSON.parse(response)

        puts ""
        # delete ios signing_keys
        puts "+ Delete iOS signing-key: "
        json['keys']['ios']['all'].each do |i|
            url = base_url + i['link']
            private_resource = RestClient::Resource.new url , {:user => username , :password => password , :timeout => 30}
            response = private_resource.delete 
            puts "+   " + response.to_str
        end
        # delete android signing_keys
        puts "+ Delete Android signing-key: "
        json['keys']['android']['all'].each do |i|
            url = base_url + i['link']
            private_resource = RestClient::Resource.new url , {:user => username , :password => password , :timeout => 30}
            response = private_resource.delete 
            puts "+   " + response.to_str
        end
        # delete blackberry signing_keys
        puts "+ Delete BlackBerry signing-key: "
        json['keys']['blackberry']['all'].each do |i|
            url = base_url + i['link']
            private_resource = RestClient::Resource.new url , {:user => username , :password => password , :timeout => 30}
            response = private_resource.delete 
            puts "+   " + response.to_str
        end
    end

    def change_element_type_by_id(options = {})
        raise "Must pass a hash containing 'id'" if not options.is_a?(Hash) or not options.has_key?(:id) 
        raise "Must pass a hash containing 'to_type'" if not options.is_a?(Hash) or not options.has_key?(:to_type)

        id = options.delete(:id)
        to_type = options.delete(:to_type)

        @driver.execute_script(
            " oldObj = document.getElementById('#{id}'); " + 
            " var newObject = document.createElement('input'); " + 
            " newObject.type = '#{to_type}'; " + 
            " if(oldObj.size) newObject.size = oldObj.size; " + 
            " if(oldObj.value) newObject.value = oldObj.value; " + 
            " if(oldObj.name) newObject.name = oldObj.name; " +
            " if(oldObj.id) newObject.id = oldObj.id; " + 
            " if(oldObj.className) newObject.className = oldObj.className; " + 
            " oldObj.parentNode.replaceChild(newObject,oldObj); "
        )
    end

    def change_element_type_by_name(options = {})
        raise "Must pass a hash containing 'name'" if not options.is_a?(Hash) or not options.has_key?(:name)
        raise "Must pass a hash containing 'to_type'" if not options.is_a?(Hash) or not options.has_key?(:to_type)

        name = options.delete(:name)
        to_type = options.delete(:to_type)
        
        @driver.execute_script(
            " oldObj = document.getElementsByName('#{name}')[0]; " + 
            " var newObject = document.createElement('input'); " + 
            " newObject.type = '#{to_type}'; " + 
            " if(oldObj.size) newObject.size = oldObj.size; " + 
            " if(oldObj.value) newObject.value = oldObj.value; " + 
            " if(oldObj.name) newObject.name = oldObj.name; " +
            " if(oldObj.id) newObject.id = oldObj.id; " + 
            " if(oldObj.className) newObject.className = oldObj.className; " + 
            " oldObj.parentNode.replaceChild(newObject,oldObj); "
        )
    end

    def go_to_page(page, url = "") 
      urls = $data[:url]  
      if urls.has_key?(page) # and @driver.current_url !~ /\S+#{urls[:page]}/
        @driver.get path_format_locale($data[:url][page], url)
      else
        raise "Sorry we do have #{page} page" 
      end
    end

    # Path formattor with locale 
    # the result address will be like 
    #   http://loc.build.phonegap.com/people/sign_in?locale=fr_FR
    def path_format_locale(path, arg_base_url = "")
        if arg_base_url == ""
            url = $base_url
        else
            url = arg_base_url
        end
        url.to_s + path + "?locale=" + $lang.to_s
    end 

    # To count the each test case's 'it' block order.
    # Ultimately it is used to name the screenshot when failure happens 
    class Counter
        attr_accessor :value
        def initialize(i = 0)
            @value = i
        end
        def inc
            @value = @value.succ
        end
    end

end    
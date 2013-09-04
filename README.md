Testing_on_Phonegap_Build
===============
The project automates the I18N testing on PhonegapBuild website, using RSpec, with Selenium::Webdriver

### Requirement:

- git
- ruby
- rspec
- selenium-webdriver 
- rake
- rest-client

### Setup

1, Install ruby environement on your Operating System. 

2, Install RSpec, Selenium-WebDriver, and rake packages with gem

    $ gem install rspec
    $ gem install selenium-webdriver
    $ gem install rest-client
    
3, Install Chromedirver if you will use chrome broswer

  3.1, For Mac
  
     3.1.1 Download chromedriver_mac_26.0.1383.0.zip from http://code.google.com/p/chromedriver/downloads/list
     3.1.2 Unzip the zip file
     3.1.3 $ echo $PATH
     3.1.4 Copy chromedriver file to one of your path file. Such as http://code.google.com/p/chromedriver/downloads/list
     3.1.5 Quit chrome broswer

4，IDE for developer(You can choose one of them)

    1. netbeans6.9.1 // the versions higher than 6.9.1 not support ruby
    2. sublime text 2 
    3. textmate 
    4. Rubymine

### Deploy manually 

1, Clone the repo to your local machine
	
	$ git clone https://github.com/YanShuai-Dilato/Selenium_on_pgb.git
	$ cd Selenium_on_pgb/


2, Please copy the folder "Selenium_on_pgb/assets" to "C:\" if you're using Windows to run this test. 


3, Manage testing task in Rakefile

   example:
	
    RSpec::Core::RakeTask.new(:spec,:osconfig) do |t|
      t.pattern = "./testcases/sign_in_rspec.rb"  
      
      # output as HTML format. for more, please check "$rspec --help"
      t.rspec_opts = "--format h > ./result_html/result_#{@t}.html "
      
	  # init config
      ENV['PGBBROWSER'] = 'chrome'
      ENV['PGBLANG'] = 'en_US'
    end 
    # Set testing browser for ENV['PGBBROWSER'] . Support 'chrome , firefox ,ie ...' . Full support can be found at http://docs.seleniumhq.org/docs/03_webdriver.jsp
    # Set the locale for ENV['PGBLANG'].By now , en_US , fr_FR, ja_JP are available.
    # Manage the running testcases for 't.pattern'.
    #
    
    
4, Run the test 

	# For OSX
    $ PGBBROWSER=firefox PGBLANG=en_US rake TC[all]      # Run all testcases
    $ PGBBROWSER=chrome  PGBLANG=fr_FR rake TC[001]      # Run the first testcase

    # For Windows
    C:\Selenium_on_pgb> set PGBBROWSER=firefox
    C:\Selenium_on_pgb> set PGBLANG=en_US
    C:\Selenium_on_pgb> rake TC[001]
	
	
5, Then you can find the result file (log.txt) at the following directory. 
	
    $ open ./auto_results/#{lang}_#{browser}/selenium_result.txt
	

### Schedule your task
###### For OSX
We use *crontab* utility to schedule our tasks. 

1, Use the following command to list your active crontab entries, and to remove the current crontab if there is one.  

    $ crontab -l  
    $ crontab -r    # to remove the current crontab. 
    
2, Create crontab file. 

A crontab file has six fields for specifying minute, hour, day of month, month, day of week and the command to be run at that interval. See below:

    *     *     *     *     *  command to be executed
    -     -     -     -     -
    |     |     |     |     |
    |     |     |     |     +----- day of week (0 - 6) (Sunday=0)
    |     |     |     +------- month (1 - 12)
    |     |     +--------- day of month (1 - 31)
    |     +----------- hour (0 - 23)
    +------------- min (0 - 59)
    
As for our situation: 

    $ cat ./crontab.txt
    $ 30 23 * * * rm path/to/dir/ -rf

3, Specifying a crontab file to use

    $ crontab ./crontab.txt
    
    

###### For Windows

We use the "Task Scheduler" tool located in "Control" -> "Administrative Tools"

The command was: 

    
    RMDIR /s /q i_am_the_folder




### Code structure
https://www.dropbox.com/s/fd9cvodechaj26l/selenium_Logical_view_Draft.png


### Test cases 


    TC_002_new_app_paid_account_spec.rb
    TC_003_register_create_adobe_id_spec.rb
    TC_004_register_free_plan_with_adobe_id_spec.rb
    TC_005_register_free_plan_with_github_id_spec.rb
    TC_006_register_paid_ccm_spec.rb
    TC_007_register_upgrade_plan_spec.rb
    TC_008_sign_in_spec.rb
    TC_009_signing_key_add_unlock_delete_spec.rb
    TC_010_plugins_before_sign_in_spec.rb
    TC_011_plugins_after_sign_in_spec.rb
    TC_012_account_detail_spec.rb
    TC_013_account_sign_delete_spec.rb
    TC_014_account_edit_private_code_hosting_spec.rb






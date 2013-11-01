#encoding: utf-8

require 'rake'
require 'rspec/core/rake_task'
require 'fileutils'

require_relative "./util/config_param"

# Uses FileList to get an Array of the configuration files
TESTCASE_FILES=FileList['testcase/*.rb']

def init_folders
    browser = ENV['PGBBROWSER']
    lang = ENV['PGBLANG']
    name_subdir = "#{lang}_#{browser}" 
    initialize_params name_subdir
    name_subdir
end

if defined? RSpec
    include ConfigParam

    RSpec::Core::RakeTask.new(:TC, :order) do |t, args| 
        raise "Please specify the testcase number to run, like TC[001], or TC[all] to run all testcases ! " unless args.order
        str_time = Time.now.strftime("%Y%m%d%H%M").to_s
        
        if "ALL" == args.order.upcase
            name_subdir = init_folders 
            puts "------ Running all testcases ------" 
            t.pattern = "./testcase/*_spec.rb"
            t.rspec_opts = "--format d >> ./auto_results/#{name_subdir}/all_result_#{str_time}.txt "
        elsif TESTCASE_FILES.find { |e| e.include?("#{args.order}") }  
            name_subdir = init_folders  
            puts "TC[#{args.order}] is now running ..."
            t.pattern = "./testcase/TC_#{args.order}*.rb"
            t.rspec_opts = "--format d > ./auto_results/#{name_subdir}/TC_#{args.order}_result_#{str_time}.txt "
        else
            raise "Please specify the testcase number to run, like TC[001], or TC[all] to run all testcases ! "
        end
    end

end

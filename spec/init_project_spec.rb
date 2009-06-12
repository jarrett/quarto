require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'fileutils'

describe Quarto do
	include Quarto::FileMatchers
	
	context '.init_project on an empty directory' do
		before :all do
			@temp_project_path = SAMPLE_DIR + '/../temp_sample_project'
			FileUtils::rm_rf @temp_project_path
			Quarto.init_project(@temp_project_path)
		end
		
		after :all do
			FileUtils::rm_rf @temp_project_path
		end
		
		it 'should create the project folder' do
			@temp_project_path.should exist_on_disk
		end
		
		it 'should create all the subfolders' do
			Quarto::PROJECT_SUBFOLDERS.each do |folder|
				(@temp_project_path + '/' + folder).should exist_on_disk
			end
		end
		
		it 'should create a starter generate.rb' do
			generate_file = @temp_project_path + '/generate.rb'
			generate_file.should exist_on_disk
			File.read(generate_file).should == Quarto::STARTER_GENERATE_FILE
		end
		
		it 'should not raise an error if the user attempts to reinitialize an existing project' do
			Quarto.init_project(@temp_project_path)
		end
		
		it 'should return true on success' do
			Quarto.init_project(@temp_project_path).should == true
		end
	end
end
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'fileutils'

describe Quarto do
	context '.generatate' do
		class MockGenerator
			def generate(&block)
				instance_eval(&block)
			end
			
			def do_something_in_the_block; end
		end
		
		before :each do
			@mock_generator = MockGenerator.new
			Quarto::Generator.stub!(:new).and_return(@mock_generator)
		end
		
		after :each do
			# This must happen after the mocking has been configured for each example
			# Otherwise, none of the mocking will have any effect
			Quarto.generate(SAMPLE_DIR) do
				do_something_in_the_block
			end
		end
		
		it 'should call Quarto::Generator.new and pass the project directory' do
			Quarto::Generator.should_receive(:new).with(SAMPLE_DIR).and_return(@mock_generator)
		end
		
		it 'should call #generate on the Generator' do
			@mock_generator.should_receive(:generate)
		end
		
		it 'should execute the block in the context of the Generator' do
			@mock_generator.should_receive(:do_something_in_the_block)
		end
	end
end

module Quarto
	# This will be used in the specs below--see the method aliasing
	def self.testable_generate(&block)
		GenerationTesting.generation_block = block
	end
	
	module GenerationTesting
		def self.generation_block
			@generation_block
		end
		
		def self.generation_block=(block)
			@generation_block = block
		end
	end
end

describe Quarto::Generator do
	context '.new' do
		it 'should accept a path to a project directory' do
			Quarto::Generator.new(SAMPLE_DIR).should be_a(Quarto::Generator)
		end
	end
	
	context '#generate from the sample project' do
		include Quarto::UrlHelper
		
		before :all do
			# Quarto.generate will now return the passed block as a proc
			# instead of envoking the whole framework
			Quarto.module_eval do
				class << self
					
					alias_method :untestable_generate, :generate
					alias_method :generate, :testable_generate
				end
			end
			
			@generator = Quarto::Generator.new(SAMPLE_DIR)
			
			# Clear the directories
			FileUtils.rm_rf @generator.output_path
			
			# Now that we've aliased the methods and load has been called GenerationTesting.generation_block should be set
			load @generator.generate_file_path
			@generator.generate(&Quarto::GenerationTesting.generation_block)
		end
		
		after :all do
			# Reset Quarto.generate to its old behavior
			Quarto.module_eval do
				class << self
					alias_method :generate, :untestable_generate
				end
			end
		end
		
		it 'should set #output_path' do
			@generator.output_path.should == SAMPLE_DIR + '/output'
		end
		
		it 'should create a directory under #output_path' do
			File.exists?(@generator.output_path).should be_true
		end
		
		it 'should create a single file for all the companies' do
			Dir.glob(@generator.output_path + '/*.html').collect { |f| File.basename(f) }.should == ['companies.html']
		end
		
		it 'should create one file for each employee' do
			expected_files = ['DHH', 'Jamis Buck', 'Hank Hill', 'Buckley', 'Apu Nahasapeemapetilon', 'Kenan Thompson', 'Kel Mitchell', 'Marvin'].sort.collect do |name|
				urlize(name) + '.html'
			end
			Dir.glob(@generator.output_path + '/employees/*.html').collect { |f| File.basename(f) }.sort.should == expected_files
		end
	end
end
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Quarto::Generator do
	context '.new' do
		it 'should accept a path to a project directory' do
			Quarto::Generator.new(SAMPLE_DIR).should be_a(Quarto::Generator)
		end
	end
	
	context '#generate from the sample project' do
		include Quarto::UrlHelper
		
		before :all do
			@generator = Quarto::Generator.new(SAMPLE_DIR)
			@generator.generate
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
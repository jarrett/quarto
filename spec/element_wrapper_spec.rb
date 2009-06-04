require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/sample_project/models/company')
require File.expand_path(File.dirname(__FILE__) + '/sample_project/models/employee')

describe Quarto::ElementWrapper do
	before :each do
		Quarto.xml_source = File.open(SAMPLE_DIR + '/xml/companies.xml')
		@xml = Quarto.xml_doc
	end
	
	context 'wrapping an element with attributes and children' do
		before :each do
			@element = @xml.elements['companies/company']
			@company = Company.new(@element)
		end
		
		it 'should instantiate a subclass of Quarto::ElementWrapper' do
			@company.should be_a(Quarto::ElementWrapper)
		end
		
		it 'should define methods from specified child elements' do
			@company.should respond_to(:name)
			@company.name.should == '37Signals'
		end
		
		it 'should define methods from XML attributes by default' do
			@company.should respond_to(:reality)
			@company.reality.should == 'real'
		end
		
		it 'should expose methods of the underlying REXML::Element' do
			# Just test a few methods that don't require parameters
			[:root_node, :text, :node_type, :document, :children].each do |meth|
				@company.should respond_to(meth)
				@company.send(meth).should == @element.send(meth)
			end
		end
		
		it 'should set the element_name based on the class name' do
			Company.element_name.should == 'company'
		end
	end
	
	context '.new' do
		it 'should raise ArgumentError if it is passed anything other than a REXML::Element' do
			[nil, 'foo', 1].each do |bad|
				lambda { Company.new(bad) }.should raise_error(ArgumentError)
			end
		end
	end
	
	context '#find' do
		it 'should find matching elements based on :xpath' do
			companies = Company.find(:all, :xpath => 'companies/company')
			companies.should be_a(Array)
			companies.each do |company|
				company.should be_a(Company)
			end
			companies = Company.find(:all, :xpath => "companies/company[@reality='real']")
			companies.should be_a(Array)
			companies.length.should == 1 # There is one real company in the example XML file: 37Signals
			companies[0].name.should == '37Signals'
			
			companies = Company.find(:all, :xpath => "companies/company[name='Milliways']")
			companies.should be_a(Array)
			companies.length.should == 1
			companies[0].name.should == 'Milliways'
		end
		
		it 'should work without the :xpath parameter' do
			Company.find(:all).should == Company.find(:all, :xpath => '//company')
			Employee.find(:all).should == Employee.find(:all, :xpath => '//employee')
		end
		
		it 'should return all matching elements when the quantifier is :all' do
			companies = Company.find(:all, :xpath => 'companies/company')
			companies.length.should == 5 # There are five companies in the example XML file
		end
		
		it 'should return the first matching element when the quantifier is :first' do
			company = Company.find(:first, :xpath => 'companies/company')
			company.should be_a(Company)
			company.name.should == '37Signals'
		end
		
		it 'should return the last matching element when the quantifier is :first' do
			company = Company.find(:last, :xpath => 'companies/company')
			company.should be_a(Company)
			company.name.should == 'Milliways'
		end
	end
end


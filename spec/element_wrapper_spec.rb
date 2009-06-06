require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/sample_models')

describe Quarto::ElementWrapper::Base do
	before :each do
		Quarto.xml_source = File.open(SAMPLE_DIR + '/xml/companies.xml')
		@xml = Quarto.xml_doc
	end
	
	context 'wrapping an element with attributes' do
		before :each do
			@element = @xml.elements['companies/company']
			@company = Company.new(@element)
		end
		
		it 'should instantiate a subclass of Quarto::ElementWrapper::Base' do
			@company.should be_a(Quarto::ElementWrapper::Base)
		end
		
		it 'should define attributes from specified elements' do
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
	
	context 'wrapping an element that only contains text' do
		before :each do
			@product = Product.find(:first, :xpath => "//product[text()='Propane']")
		end
		
		it 'should link an attribute to the element\'s text' do
			@product.name.should == 'Propane'
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
			companies.length.should == 5
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
		
		it 'should return an empty array with :all and an XPath that yields nothing' do
			Company.find(:all, :xpath => "companies/company[foo='bar']").should == []
		end
		
		it 'should return nil with :first or :last and an XPath that yields nothing' do
			Company.find(:first, :xpath => "companies/company[foo='bar']").should == nil
			Company.find(:last, :xpath => "companies/company[foo='bar']").should == nil
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
	
	context '#==' do
		before :each do
			@element_1 = @xml.elements['companies/company']
			@element_2 = @xml.elements['companies/company[last()]']
		end
		
		it 'should return true for two ElementWrapper::Base instances that wrap the same element' do
			Quarto::ElementWrapper::Base.new(@element_1).should == Quarto::ElementWrapper::Base.new(@element_1)
		end
		
		it 'should return false for two ElementWrapper::Base instaces that wrap different elements' do
			Quarto::ElementWrapper::Base.new(@element_1).should_not == Quarto::ElementWrapper::Base.new(@element_2)
		end
		
		it 'should return false if the second object is not an instance of ElementWrapper::Base' do
			Quarto::ElementWrapper::Base.new(@element_1).should_not == 'foo'
		end
	end
end


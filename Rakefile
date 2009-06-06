begin
	require 'jeweler'
	Jeweler::Tasks.new do |gemspec|
		gemspec.name = 'quarto'
		gemspec.summary = 'generates HTML or any other format from XML'
		gemspec.email = 'jarrett@uchicago.edu'
		gemspec.homepage = 'http://github.com/jarrett/quarto'
		gemspec.description = 'Quarto is a Ruby framework for generating collections of documents from XML. It steps in where XSLT just won\'t cut it. ' +
			'Potential applications include web sites and e-books. It\'s built on top of ERB and REXML.'
		gemspec.authors = ['Jarrett Colby']
		gemspec.files = FileList['[A-Z]*', '{bin,lib,test}/**/*']
		gemspec.executables = 'quarto'
		gemspec.add_dependency('activesupport', '>= 2.3.2')
	end
rescue LoadError
	puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
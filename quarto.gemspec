# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{quarto}
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jarrett Colby"]
  s.date = %q{2009-06-09}
  s.default_executable = %q{quarto}
  s.description = %q{Quarto is a Ruby framework for generating collections of documents from XML. It steps in where XSLT just won't cut it. Potential applications include web sites and e-books. It's built on top of ERB and REXML.}
  s.email = %q{jarrett@uchicago.edu}
  s.executables = ["quarto"]
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "README",
     "Rakefile",
     "VERSION",
     "bin/quarto",
     "lib/quarto.rb",
     "lib/quarto/children.rb",
     "lib/quarto/config.rb",
     "lib/quarto/element_wrapper.rb",
     "lib/quarto/generator.rb",
     "lib/quarto/inheritable_attributes.rb",
     "lib/quarto/init_project.rb",
     "lib/quarto/rendering.rb",
     "lib/quarto/url_helper.rb",
     "lib/quarto/xml_doc.rb",
     "quarto.gemspec",
     "test.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jarrett/quarto}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{generates HTML or any other format from XML}
  s.test_files = [
    "spec/children_spec.rb",
     "spec/element_wrapper_spec.rb",
     "spec/generator_spec.rb",
     "spec/init_project_spec.rb",
     "spec/matchers/file_matchers.rb",
     "spec/rendering_spec.rb",
     "spec/sample_models.rb",
     "spec/sample_project/generate.rb",
     "spec/sample_project/models/company.rb",
     "spec/sample_project/models/employee.rb",
     "spec/sample_project/models/location.rb",
     "spec/sample_project/models/mascot.rb",
     "spec/sample_project/models/product.rb",
     "spec/sample_project/urls.rb",
     "spec/spec_helper.rb",
     "spec/url_helper_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.2"])
  end
end

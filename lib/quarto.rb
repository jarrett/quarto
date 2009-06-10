$: << File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'rexml/document'
require 'erb'
require 'active_support/inflector'
require 'fileutils'

require 'quarto/config'
require 'quarto/xml_doc'
require 'quarto/inheritable_attributes'
require 'quarto/url_helper'
require 'quarto/rails_helper'
require 'quarto/element_wrapper'
require 'quarto/children'
require 'quarto/rendering'
require 'quarto/generator'
require 'quarto/init_project'

# Quarto is a Ruby framework for generating collections of documents from XML. Potential applications
# include web sites and e-books. It's built on top of ERB and REXML.
#
# Quarto was built with HTML output in mind, but there's nothing to prevent you from outputting
# to any other format. You could even output to an interpolated scripting language like PHP.
#
# =Why Quarto?
#
# Say you have a book in XML format, and you want to make a web site from it. You could transform it
# to HTML using XSLT. But what if you need logic that can't be implemented in XSLT?
#
# Enter Quarto. Instead of writing a series of XSLT sheets, you write ERB templates. You implement
# whatever custom logic you need in classes that wrap the DOM elements, then you pass variables to the templates.
#
# =Installation
#
#   gem sources -a http://gems.github.com
#   sudo gem install jarrett-quarto
#
# =Using Quarto
#
# Thorough documentation doesn't exist yet. For now, see spec/sample_project and the RDoc.

module Quarto
end
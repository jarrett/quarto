$: << File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'rexml/document'
require 'erb'
require 'active_support/inflector'

require 'quarto/xml_doc'
require 'quarto/inheritable_attributes'
require 'quarto/element_wrapper'
require 'quarto/children'

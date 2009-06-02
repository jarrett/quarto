require 'rubygems'
require 'test/unit'
require 'spec'

SPEC_DIR = File.expand_path(File.dirname(__FILE__))
SAMPLE_DIR = SPEC_DIR + '/sample_project'

require(File.expand_path(File.dirname(__FILE__)) + '/../lib/quarto')
require(File.expand_path(File.dirname(__FILE__)) + '/sample_project/models/company')
require(File.expand_path(File.dirname(__FILE__)) + '/sample_project/models/employee')
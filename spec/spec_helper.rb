require 'rubygems'
require 'test/unit'
require 'spec'

SPEC_DIR = File.expand_path(File.dirname(__FILE__))
SAMPLE_DIR = SPEC_DIR + '/sample_project'

require(File.expand_path(File.dirname(__FILE__)) + '/../lib/quarto')

Dir.glob(SPEC_DIR + '/matchers/*.rb').each do |matcher_lib|
	require matcher_lib
end

#def puts(str)
#	raise "puts('#{str}') called"
#end
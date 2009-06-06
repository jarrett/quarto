require 'cgi'

module Quarto
	
	# This module is included in Generator and thus made available in <tt>generate.rb</tt> files.
	
	module UrlHelper
		# Generates an absolute URL, using the <tt>:site_root</tt> config value. (To change <tt>:site_root</tt>,
		# put something like this in <tt>generate.rb</tt>:
		#   config(:site_root, 'http://your_domain.com/whatever')
		def abs_url(str)
			"#{Quarto.config[:site_root]}#{str}"
		end
		
		# Replaces spaces with dashes and deletes special characters.
		def urlize(str)
			str.to_s.gsub(/[^ a-zA-Z0-9_-]/, '').tr(' ', '-')
		end
	end
end
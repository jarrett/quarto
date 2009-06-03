require 'cgi'

module Quarto
	module UrlHelper
		def abs_url(str)
			"#{Quarto.config[:site_root]}#{str}"
		end
		
		def urlize(str)
			str.to_s.gsub(/[^ a-zA-Z0-9_-]/, '').tr(' ', '-')
		end
	end
end
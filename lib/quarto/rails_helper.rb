module Quarto
	module RailsHelper
		def rails?
			defined? RAILS_GEM_VERSION
		end
	end
end
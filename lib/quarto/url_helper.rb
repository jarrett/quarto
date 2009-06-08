require 'cgi'

module Quarto
	
	# This module is included in Generator and thus made available in <tt>generate.rb</tt> files.
	
	module UrlHelper
		def self.included(base)
			if defined? RAILS_GEM_VERSION
				base.class_eval do
					alias_method :url_for_without_element_wrapper, :url_for
					alias_method :url_for, :url_for_with_element_wrapper
				end
			end
		end
		
		# Generates an absolute URL, using the <tt>:site_root</tt> config value. (To change <tt>:site_root</tt>,
		# put something like this in <tt>generate.rb</tt>:
		#   config(:site_root, 'http://your_domain.com/whatever')
		def abs_url(str)
			"#{Quarto.config[:site_root]}#{str}"
		end
		
		def url_for_with_element_wrapper(options = {})
			if options.is_a?(Quarto::ElementWrapper::Base)
				if options.respond_to?(:to_path)
					return options.to_path
				else
					raise "#{options.class} must define to_path if you want to pass an instance into link_to or url_for"
				end
			else
				return url_for_without_element_wrapper(options)
			end
		end
		
		# Replaces spaces with dashes and deletes special characters.
		def urlize(str)
			str.to_s.gsub(/[^ a-zA-Z0-9_-]/, '').tr(' ', '-')
		end
			
		unless defined? RAILS_GEM_VERSION
			# Similar to Rails' <tt>link_to</tt>, but with less flexibility. Anything you pass to this
			# <tt>link_to</tt> will also work in Rails, but the reverse is not true.
			#
			# This method is only defined if you're not using Quarto within Rails. If you are,
			# the Rails <tt>link_to</tt> will not be overriden by this one. However, you can still pass
			# instances of ElementWrapper::Base in, because Quarto patches <tt>url_for</tt> (which is
			# called by Rails' <tt>link_to</tt>).
			def link_to(text, url_or_element_wrapper, options = {})
				if url_or_element_wrapper.is_a?(String)
					url = url_or_element_wrapper
				elsif url_or_element_wrapper.is_a?(Quarto::ElementWrapper::Base)
					url = url_for(url_or_element_wrapper)
				else
					raise ArgumentError, "Expected String or ElementWrapper::Base, but got #{url_or_element_wrapper.inspect}"
				end
				options = {:html_attributes => {}}.merge(options)
				output = "<a href=\"#{url}\""
				options[:html_attributes].each do |attr, value|
					output << " #{attr}=\"#{value}\""
				end
			end
			
			# Somewhat compatible with the Rails url_for helper.
			def url_for(options = {})
				url_for_with_element_wrapper(options)
			end
		end
	end
end
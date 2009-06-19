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
		
		# Generates an absolute path, using the <tt>:site_root</tt> config value. (To change <tt>:site_root</tt>,
		# put something like this in <tt>generate.rb</tt>:
		#   config(:site_root, 'http://your_domain.com/whatever')
		def abs_path(str)
			"#{Quarto.config[:site_root]}#{str}"
		end
		
		def abs_url(str)
			warn 'Quarto::UrlHelper#abs_url is deprecated. Use abs_path instead.'
			abs_path(str)
		end
		
		# Generates a relative path based on the location of the current output file and +path+.
		# +path+ must be relative to the project's output directory. For example, if
		# the current output file is in <tt>output/employees</tt>, and you call
		# <tt>relative_path('images/foo.jpg')</tt>, the result will be <tt>../images/foo.jpg</tt>.
		def relative_path(path)
			current_hierarchy = output_file_path.split('/')
			target_hierarchy = path.split('/')
			while current_hierarchy[0] == target_hierarchy[0]
				current_hierarchy.shift
				target_hierarchy.shift
			end
			rel_path = current_hierarchy.inject('') do |result, dir|
				result + '../'
			end
			#puts target_hierarchy.inspect
			rel_path << target_hierarchy.join('/')
		end
		
		def url_for_with_element_wrapper(options = {})
			if options.is_a?(Quarto::ElementWrapper::Base)
				if options.respond_to?(:to_path)
					return options.to_path
				else
					raise "#{options.class} must define to_path if you want to pass an instance into link_to or url_for"
				end
			else
				if defined? RAILS_GEM_VERSION
					return url_for_without_element_wrapper(options)
				else
					raise ArgumentError, "Don\'t know how to generate URL from #{options.inspect}"
				end
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
			# instances of <tt>ElementWrapper::Base</tt> in, because Quarto patches <tt>url_for</tt> (which is
			# called by Rails' <tt>link_to</tt>).
			#
			# +target+ must be either an instance of <tt>ElementWrapper::Base</tt>, an absolute URL, or
			# a relative URL.
			def link_to(text, target, options = {})
				if !target.is_a?(String) and !target.is_a?(Quarto::ElementWrapper::Base)
					raise ArgumentError, "Expected String or ElementWrapper::Base, but got #{target.inspect}"
				end
				url = url_for(target)
				options = {:html_options => {}}.merge(options)
				output = "<a href=\"#{url}\""
				options[:html_options].each do |attr, value|
					output << " #{attr}=\"#{value}\""
				end
				output + '>' + text + '</a>'
			end
			
			# Somewhat compatible with the Rails url_for helper.
			def url_for(options = {})
				if options.is_a?(String)
					options
				else
					url_for_with_element_wrapper(options)
				end
			end
		end
	end
end
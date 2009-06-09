module Quarto
	# Generates the project according to the directives in the block.
	# A block must be supplied. The block will be evaluated within the context of
	# a Quarto::Generator object.
	#
	# If the optional +project_path+ is given, the directives in the block willl
	# be process for the project residing +project_path+. Otherwise, the current
	# working directory will be used.
	#
	# This method is typically called from <tt>generate.rb</tt>. There's probably
	# no reason for you to call it from any other context.
	def self.generate(project_path = nil, &block)
		unless block_given?
			raise ArgumentError, 'Quarto.generate must be given a block'
		end
		# caller[0] returns the trace for the context that called generate. So, if generate.rb is invoked directly, Quarto will still work.
		trace = caller()
		unless trace.empty?
			calling_file = trace[0].split(':')[-2]
			if File.basename(calling_file) == 'generate.rb'
				project_path = project_path || File.expand_path(File.dirname(calling_file))
			end
		end
		unless project_path.is_a?(String) and !project_path.empty?
			raise ArgumentError, 'project_path is required when Quarto.generate is called from any file other than generate.rb'
		end
		Dir.glob(project_path + '/models/*.rb').each do |model_file|
			require model_file
		end
		generator = Quarto::Generator.new(project_path)
		generator.generate(&block)
		generator
	end
	
	# Generates the project at the specified path using its generate.rb.
	def self.generate_from_project_path(project_path)
		raise ArgumentError, "Expected string, but got #{project_path.inspect}" unless project_path.is_a?(String) and !project_path.empty?
		load(project_path + '/generate.rb')
	end
	
	# This class responds to all the directives that are available for use within
	# a generate.rb file.
	class Generator
		include UrlHelper
		
		# Sets the name of the default layout file in the layouts directory. If
		# default_layout isn't specified, the default layout is the first file matching <tt>default.*</tt>.
		attr_accessor :default_layout
		
		# Generate the project according to the directives given in the block.
		def generate(&block)
			raise ArgumentError, 'generate must be called with a block' unless block_given?
			if !File.exists? @output_path
				Dir.mkdir @output_path
			end
			instance_eval(&block)
		end
		
		def generate_file_path # :nodoc:
			@project_path + '/generate.rb'
		end
		
		# Options:
		# * <tt>:console_output</tt> - Boolean. If true, the generator will print what it's currently doing.
		# * <tt>:console</tt> - By default, console messages will be printed to stdout. You can override this
		#   by passing in an object that responds to <tt>puts</tt>.
		def initialize(project_path, options = {})
			raise ArgumentError, "Expected string, but got #{project_path.inspect}" unless project_path.is_a?(String) and !project_path.empty?
			raise ArgumentError, "Project path #{project_path} doesn't exist" unless File.exists?(project_path)
			@project_path = project_path
			@output_path = project_path + '/output'
			@options = {:console_output => true, :console => Kernel}.merge(options)
			@console = @options[:console]
		end
		
		def urls_file_path # :nodoc:
			@project_path + '/urls.rb'
		end
		
		attr_reader :output_path # :nodoc:
		
		protected
		
		# Set a configuration for Quarto to use during generation, e.g. <tt>:site_root</tt>
		def config(key, value)
			Quarto.config[key] = value
		end
		
		# Render the given +template+, and save the output in +filename+ under +directory+.
		# +locals+ is a hash where they keys are the names of local variables in the template
		#
		# Options:
		# * <tt>:layout</tt> - Render inside the specified layout. Must be the name of
		#   a file in the layouts directory, e.g. <tt>my_layout.html.erb</tt>. If not given,
		#   the <tt>default_layout</tt> will be used.
		#
		# Example:
		#   employees.each do |employee|
		#     render 'employee.html.erb', 'employees', urlize(employee.name) + '.html', :employee => employee
		#   end
		#
		# That example will create a number of files with names like "John-Smith.html"
		# in the "employees" directory
		def render(template, directory, filename, locals, options = {})
			if @options[:console_output]
				if directory.is_a?(String) and !directory.empty?
					@console.puts "Writing from template #{template} to output/#{directory}/#{filename}"
				else
					@console.puts "Writing from template #{template} to output/#{filename}"
				end
			end
			
			if directory.nil? or directory.empty?
				path = "#{@output_path}/#{filename}"
			else
				subdir = "#{@output_path}/#{directory}"
				if !File.exists? subdir
					FileUtils::mkdir_p subdir
				end
				path = "#{subdir}/#{filename}"
			end
			
			File.open(path, 'w') do |file|
				file.print render_to_s(template, locals, options)
			end
		end
		
		# Renders +template+ to a string. Sets local variables within the template to the values given
		# in +locals+.
		def render_to_s(template, locals, options = {})
			require urls_file_path
			
			page_template_path = "#{@project_path}/pages/#{template}"
			page_template = ERB.new(File.read(page_template_path))
			page_content = Rendering.render(page_template, locals, [Quarto::ProjectUrls])
			
			if options.has_key?(:layout)
				layout = options[:layout]
			elsif (@default_layout and File.exists?("#{@project_path}/layouts/#{@default_layout}"))
				layout = @default_layout
			elsif @default_layout = Dir.glob("#{@project_path}/layouts/default.*.erb")[0]
				@default_layout = File.basename(@default_layout)
				layout = @default_layout
			else
				layout = nil
			end
			
			if layout
				layout_template_path = "#{@project_path}/layouts/#{layout}"
				raise ArgumentError, "Template doesn't exist: #{layout_template_path}" unless File.exists?(layout_template_path)
				layout_template = ERB.new(File.read(layout_template_path))
				Rendering.render(layout_template, locals, [Quarto::ProjectUrls]) do
					page_content
				end
			else
				page_content
			end
		end
		
		# Specifies which XML file to use. Must be the name of a file in the xml directory, e.g. <tt>companies.xml</tt>.
		# This method absolutely must be called within <tt>generate.rb</tt>. Otherwise, Quarto won't know what XML
		# to use as its source.
		def use_xml(xml_filename)
			Quarto.xml_source = File.open("#{@project_path}/xml/#{xml_filename}")
		end
	end
end
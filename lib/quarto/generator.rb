module Quarto
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
	
	def self.generate_from_project_path(project_path)
		raise ArgumentError, "Expected string, but got #{project_path.inspect}" unless project_path.is_a?(String) and !project_path.empty?
		load(project_path + '/generate.rb')
	end
	
	class Generator
		include UrlHelper
		
		attr_accessor :default_layout
		
		def generate(&block)
			raise ArgumentError, 'generate must be called with a block' unless block_given?
			if !File.exists? @output_path
				Dir.mkdir @output_path
			end
			instance_eval(&block)
		end
		
		def generate_file_path
			@project_path + '/generate.rb'
		end
		
		def initialize(project_path, options = {})
			raise ArgumentError, "Expected string, but got #{project_path.inspect}" unless project_path.is_a?(String) and !project_path.empty?
			raise ArgumentError, "Project path #{project_path} doesn't exist" unless File.exists?(project_path)
			@project_path = project_path
			@output_path = project_path + '/output'
			@options = {:console_output => true, :console => Kernel}.merge(options)
			@console = @options[:console]
		end
		
		attr_reader :output_path
		
		protected
		
		# Render the given +template+, and save the output in +filename+ under +directory+.
		# +locals+ is a hash where they keys are the names of local variables in the template
		# Example:
		#   employees.each do |employee|
		#     render 'employee.html.erb', 'employees', urlize(employee.name) + '.html', :employee => employee
		#   end
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
					Dir.mkdir subdir
				end
				path = "#{subdir}/#{filename}"
			end
			
			File.open(path, 'w') do |file|
				file.print render_to_s(template, locals, options)
			end
		end
		
		def render_to_s(template, locals, options = {})
			page_template_path = "#{@project_path}/pages/#{template}"
			page_template = ERB.new(File.read(page_template_path))
			page_content = Rendering.render(page_template, locals)
			
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
				layout_template = ERB.new(File.read(layout_template_path))
				Rendering.render(layout_template, locals) do
					page_content
				end
			else
				page_content
			end
		end
		
		def use_xml(xml_filename)
			Quarto.xml_source = File.open("#{@project_path}/xml/#{xml_filename}")
		end
	end
end
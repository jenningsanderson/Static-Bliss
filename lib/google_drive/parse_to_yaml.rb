require 'google_drive'
require 'yaml'

#Relative Requirements
require_relative 'object_types'

class GoogleDriveYAMLParser

	attr_accessor :google_drive_data

	def initialize(username=nil, password=nil, site_config)
		@session = GoogleDrive.login(username,password)
		@site_config = site_config
	end

	def read_sheet(key, sheet, object_type, parameters) #That is, name of workbook and then sheet title

		ws = @session.spreadsheet_by_key(key).worksheet_by_title(sheet)

		#Load the previous value, if it exists

		begin
			puts "Attempting to load previous data file for #{object_type} of type #{sheet}"
			prev_file = YAML::load(File.open("#{@site_config['data_directory']}/#{sheet.downcase}.yml")) || []
			puts "Successfully loaded previous data file"
		rescue
			puts "No previous data file for #{object_type}, no problem, just make sure all google data exists"
			prev_file = []	
		end

		#print prev_file

		objects = []
		
		#Assumes that 3rd row is header (Which it is by design)
		(4..ws.num_rows.to_i).to_a.each do |r|	# Iterate through every row
			object = {}							# Make an empty hash for a row
			(1..ws.num_cols).to_a.each do |c|  	# Iterate over columns, load hash
				object[ws[3,c]] = ws[r,c]
			end

			#Account for empty cells
			if object['name']==""	#As long as name is empty, object doesn't parse
				next
			end

			#Evaluate the object type (Must actually exist!)
			begin
				this_object = eval(object_type).new(object['name'], sheet.capitalize)
			rescue
				puts "Error! The object type #{object_type} may not exist"
			end
			#Now add keys as instance variables to the person... Cool!
			object.each do |k,v|
				unless v==""
					this_object.instance_variable_set("@#{k}", v)
				end
			end

			unless prev_file.empty?
				previous_data = prev_file[prev_file.index {|h| h['name'] == this_object.name }]
			else
				previous_data = []
			end
			
			this_object.validate(parameters, previous_data)

			objects << this_object	#Add the object to the objects array
		end
		return objects
	end

	def write_to_yaml(objects, directory, filename)
		to_write = []
		
		objects.each do |object|
			this_object = {}
			object.instance_variables.each do |k|
				this_object[k.to_s.gsub('@','')] = object.instance_eval(k.to_s)
			end
			to_write << this_object
		end

		#Actually write the file
		begin
			unless File.directory?(directory)
				Dir.mkdir directory
			end
			File.open(directory+'/'+filename.downcase+'.yml', 'wb') {|f|
				f.write(to_write.to_yaml)
			}
			puts "file: '#{directory}/#{filename.downcase}.yml' written sucessfully" 
		rescue => error
			puts "Failed to write YAML file:"
			puts error.inspect
			puts error.backtrace
		end
		
		return to_write
	end
end #End YAMLAuthor
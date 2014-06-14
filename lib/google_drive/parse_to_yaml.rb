require 'google_drive'
require 'yaml'

#Relative Requirements
require_relative 'object_types'

class GoogleDriveYAMLParser

	attr_accessor :google_drive_data

	def initialize(username=nil, password=nil)
		username ||= "cuprojectepic@gmail.com"		# When it actually hits production,
		password ||= "CrisisInformatics2014"		# we will remove this
		@session = GoogleDrive.login(username,password)

		@yml_config 		= YAML::load(File.open('_config.yml'))
		@google_drive_data 	= yml_config['google_info']
		@write_directory 	= yml_config['write_directory']
	end

	def set_parameters(params)
		@params = params
	end

	def read_sheet(key, sheet, object_type) #That is, name of workbook and then sheet title
		ws = @session.spreadsheet_by_key(key).worksheet_by_title(sheet)
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

			this_object.validate(params)

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
			File.open(directory+'/'+filename.downcase+'.yml', 'wb') {|f|
				f.write(to_write.to_yaml)
			}
			puts "file: '#{directory}/#{filename.downcase}.yml' written sucessfully" 
		rescue => error
			puts "Failed to write YAML file:"
			puts error
		end
		
		return to_write
	end
end #End YAMLAuthor

def update_page(type, sheet, param)
	key = @@site_data[type]['key']
	object_type=@@site_data[type]["object"]

	object_directory = @@buildtasks_dir+'/'+object_type.downcase
	puts "Requiring #{object_directory}"
	require object_directory
	
	puts "Going to Google Drive to Update: "
	puts "\tType: #{type}"
	puts "\tObject Type: #{object_type}"
	puts "\tSheet: #{sheet}"
	puts "\tKey: #{key}"

	objects = parse_spreadsheet(object_type,key,sheet, param)
	write_to_yaml(objects, @@write_directory, sheet)
	puts "==================================================================="
end

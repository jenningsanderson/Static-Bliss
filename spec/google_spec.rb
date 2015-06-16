require 'spec_helper'
require_relative '../lib/google_drive/login.rb'
require_relative '../lib/google_drive/parse_to_yaml.rb'

describe GoogleDriveHandler do
  
	before :all do
		#Load the credentials early on.
		@credentials = YAML::load(File.open('spec/_secret_config.yml'))
		@config = YAML::load(File.open('spec/_config.yml'))
		@drive = GoogleDriveHandler.new(p12: @credentials['p12'])
	end

	it "Sucessfully grabbed token" do 
		expect @drive.token != nil
	end

	it "Can authenticate with the google_drive gem and access the sheets" do 
		@drive_parser = GoogleDriveYAMLParser.new(token: @drive.token)
		
		@config['google_info'].each do |name, sheet|
			puts "Looking for: #{name}"
			puts @drive_parser.session.spreadsheet_by_key(sheet["key"])
		end
	end
end
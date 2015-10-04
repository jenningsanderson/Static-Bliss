Static-Bliss
============

A gem for modularizing Jekyll-built website updates and pushing to an s3 bucket.


###Requirements
Gem requirements (Depending on what access abilities you want)
	
	s3
	aws-sdk
	google_drive
	google-drive-api

###Directory Requirements
A ````_data```` folder at the root of your site will hold the required


###Authentication
Accessing files with the Google Drive API requires oauth2.0 authentication, this gem is set to read from a p12 key, which can be easily generated 

###Configuration
Modify your ````_config.yml```` file to include the following values:

1. google_info

Additionally, create another file called ````_secret_config.yml```` with the following contents:

	p12 : "Location to your p12 key"
	service_account : "Your service account email with google dev"

	s3_id : "S3 ID"
	s3_secret : "S3 Secret"
	production_bucket: "yourbucketnamehere"


Be sure to add the following line to your _.gitignore_ file: ````_secret*.*````

###Installation
The easiest method is to add the following line to your ```Gemfile```
	
	gem 'Static-Bliss', :git => 'git://github.com/jenningsanderson/Static-Bliss.git'

and run ```bundle install```

###Execution
If installed with bundler (recommended), then you have to execute with bundler:

	bundle exec bliss
	
If successful, you should see the following (functions dependent on configuration)

	Command: help
	args: []
	Reading the _config.yml file
	Loading site_config from _config.yml
	Loading credentials from site_config location
	
	Welcome to Static-Bliss, a gem built to make updating your jekyll site very simple.
	Loading site_config from _config.yml
	Loading credentials from site_config location
	
	The following functions are available based on your configuration:
		bliss publish
		bliss update press
		bliss update people [all]
		bliss update people Current
		bliss update people Alumni
		bliss update projects
		bliss update publications
		bliss update all
	
	Note: Additional parameters for each of these functions may be available depending on your object classes

Remember to call ```bundle exec``` before ```bliss``` when running the functions.

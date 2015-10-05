Static-Bliss
============

A gem to build YAML files from Google spreadsheets to assist in maintaining static [Jekyll](https://jekyllrb.com/) websites

###Requirements
Gem requirements (Depending on what access abilities you want)
	
	s3
	aws-sdk

###Directory Requirements
A ````_data```` folder at the root of your site will hold the generated data, this is the default Jekyll data directory available at ```site.data```


###Configuration
Modify your ````_config.yml```` file to include and entry like this:

	sheets:
		people :
			key    : 1w6uPTCA6V_6mD_02jB8WFJ5nVr6RPU_3kjfY9PQv_K0
			object : Person
			types  : ['current', 'alumni']

Where 
	1. ```update people``` will then become the command, ```key``` is the spreadsheet key
	2. ```object``` is the Ruby class from ```lib/google_drive/models.rb``` 
	3. ```types``` is an array of the titles of the worksheets, making subcommands possible: ```update people alumni```.

Additionally, create another file called ````_secret_config.yml```` with the following contents:

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
	
If successful, you should see a list of available functions (same as ```bundle exec bliss list```): 

	The following functions are available based on your configuration:
		bliss update press
		bliss update people
		bliss update people current
		bliss update people alumni
		bliss update publications

Remember to call ```bundle exec``` before ```bliss``` when running the functions.

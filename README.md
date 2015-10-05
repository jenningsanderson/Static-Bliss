Static-Bliss
============

A gem to build YAML files from Google spreadsheets to assist in maintaining Static Jekyll Websites

###Requirements
Gem requirements (Depending on what access abilities you want)
	
	s3
	aws-sdk

###Directory Requirements
A ````_data```` folder at the root of your site will hold the generated data, this is the default Jekyll data directory available at ```site.data```


###Configuration
Modify your ````_config.yml```` file to include the following values:

1. 'sheets'

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

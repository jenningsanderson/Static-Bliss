Static-Bliss
============

A gem for modularizing Jekyll-built website updates and pushing to an s3 bucket.


###Requirements
Gem requirements

###Directory Requirements
A ````_data```` folder at the root of your site will hold the required


###Configuration
Modify your ````_config.yml```` file to include the following values:

1. google_info

Additionally, create another file called ````_secret_config.yml```` with the following contents:
````
google_username : "you@gmail.com"
google_password : "qwerty1"

s3_id : "S3 ID"
s3_secret : "S3 Secret"
production_bucket: "yourbucketnamehere"
````

Be sure to add the following line to your _.gitignore_ file: ````_secret*.*````
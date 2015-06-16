require 'google/api_client'
#
#
#
# Using the p12 key associated with the account, this is the new login for this specific gem.  
# Hopefully we can once and for all fix this authentication issue

class GoogleDriveHandler

	attr_accessor :drive, :token

	def initialize(args)
		p12 = args[:p12]
		authenticate(p12)
	end

	def authenticate(p12_file_location)
		client = Google::APIClient.new(:application_name => 'Static-Bliss-Gem', :application_version => '1.0.0')
  		key = Google::APIClient::KeyUtils.load_from_pkcs12(p12_file_location, 'notasecret')
		client.authorization = Signet::OAuth2::Client.new(
		    :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
		    :audience => 'https://accounts.google.com/o/oauth2/token',
		    :scope => 'https://www.googleapis.com/auth/drive',
		    :issuer => '930506789765-aai3fnpjl3dcva20k836kk88dgnepmsn@developer.gserviceaccount.com',
		    :signing_key => key)
		@token = client.authorization.fetch_access_token!["access_token"]
	end
end
require 'rubygems'
require 'sinatra'
require 'json'
require 'httparty'
require 'awesome_print'
require 'mongo'
require 'mongoid'
require 'json/ext' 
require './model/apps.rb'
require './model/site.rb'
require './env' if File.exists?('env.rb')

require 'net/http'
require './apns.rb'

# Used for MasterCard API
require 'mastercard_api'
require 'crack'

# Passbook Creation
require 'dubai'

# Google Analytics
require 'gabba'

require 'geocoder'
#
require 'twilio-ruby'

require 'stripe'

# Set MongoID database
Mongoid.load!('mongoid.yml')

# Set Stripe api
set :publishable_key, ENV['stripe_publishable_key']
set :secret_key, ENV['stripe_secret_key']

Stripe.api_key = settings.secret_key

## Sets the variables for the site
def set_site

  host = request.host
    
	#site = Site.where(host_name: host.downcase).first
  #site = Site.where(host_name: '45bitcode.com').first
  site = Site.all.first
	@site = site
	
	@facebook = site.facebook
	@twitter = site.twitter
	@tumblr = site.tumblr
	@instagram = site.instagram
	@author = site.author
	@author_link = site.author_link
	@title = site.title
	@company = site.company
	@description = site.description
	@show_app_banner = false
	@url = site.url
	@type = 'website'
	@img_url = site.img_url
	@fb_id = site.fb_admin
	@ios_app_id = ''
	@tw_card_type = 'summary'
	@email = site.email
	@tw_id = site.tw_id
	@phone = site.phone
	@city_st_zip = site.city_st_zip
	@favicon = site.favicon
	
	if host.include? '45bitcode.com'
		@layout = 'shared/layout'
		@index = 'shared/index'
		@privacy = :privacy
		@contact = :contact
		@thankyou = :thankyou
		@oops = :oops
	else
	
	end
end

## Generic Pages ##
# These paths should be used on all sites with little change
get '/?' do
	set_site
	erb :'shared/index', :layout => :'shared/layout'
end

get '/privacy?' do
	set_site
  erb @privacy, :layout => @layout
  erb :'shared/privacy', :layout => :'shared/layout'
end

get '/contact?' do
	set_site
  #erb @contact, :layout => @layout
  erb :'shared/contact', :layout => :'shared/layout'
end

get '/thankyou?' do
	set_site
	#erb @thankyou, :layout => @layout
  erb :'shared/thankyou', :layout => :'shared/layout'
end

not_found do
	set_site
	status 404
	#erb @oops, :layout => @layout
  erb :'shared/oops', :layout => :'shared/layout'
end
## End of Generic Pages ##

## Stripe Charge Pages ##
post '/charge?' do

  amount = params[:amount]
  email = params[:email]
  description = [:desc]
  currency = [:currency]
  # Amount in cents
  @amount = 500

  customer = Stripe::Customer.create(
    :email => email,
    :card  => params[:stripeToken]
  )

  charge = Stripe::Charge.create(
    :amount      => @amount,
    :description => description,
    :currency    => current,
    :customer    => customer.id
  )

  erb :charge
end
## End of Stripe Pages ##

## API Logic ##

# Mastercard API #
get '/api/mc/v1?' do
	content_type :json

  # test URL http://localhost:4567/api/mc/v1/?length=1&offset=0&lat=41.8500300&lon=-87.6500500&radius=25&unit=miles&prod=y&uuid=fdsfsd&type=test

  lat = params[:lat]
	lon = params[:lon]
	offset = params[:offset]
	unit = params[:unit]
	radius = params[:radius]
	length = params[:length]
	prod = params[:prod]
	uuid = params[:uuid]
	type = params[:type]

	#Google Analytics PageView
  Gabba::Gabba.new('UA-58678060-3', '45bitcode.com').page_view('Mobile Pay Finder', 'api/mc')
    
  #Google Analytics Events
	Gabba::Gabba.new('UA-58678060-3', '45bitcode.com').event('API', 'GET', 'User', uuid, true)
  Gabba::Gabba.new('UA-58678060-3', '45bitcode.com').event('API', 'GET', 'type', type, true)

	if prod == 'y'
		@sandbox = ''
		@consumer_key = ENV['mastercard_consumer_key_prod']
		@private_key_path = ENV['mastercard_private_key_path_prod']
		@private_key_password = ENV['mastercard_private_key_password_prod']
	else
		@sandbox = 'sandbox.'
		@consumer_key = ENV['mastercard_consumer_key_sandbox']
		@private_key_path = ENV['mastercard_private_key_path_sandbox']
		@private_key_password = ENV['mastercard_private_key_password_sandbox']
	end

	endpoint = "https://#{@sandbox}api.mastercard.com/merchants/v1/merchant?Format=XML&Details=acceptance.paypass&PageLength=#{length}&PageOffset=#{offset}&Latitude=#{lat}&Longitude=#{lon}&DistanceUnit=#{unit}&Radius=#{radius}"
  #puts endpoint

	@private_key = OpenSSL::PKCS12.new(File.read(@private_key_path), @private_key_password).key
	@connector = Mastercard::Common::Connector.new @consumer_key, @private_key
	@oauth_params = @connector.oauth_parameters_factory
	
	response_body = @connector.do_request endpoint,'GET', ' ', @oauth_params
	
	xml  = Crack::XML.parse(response_body)
	xml.to_json
end
# End Mastercard API #

## 45 Bit Code Pages ##
get '/apps/:slug' do
	set_site
	@name = ''
	slug = params[:slug]
	
	app = App.where(slug: slug.downcase).first
	
	if app.nil?
		@title = @site.title
		@description = @site.description
		@show_app_banner = false
		@url = @site.url
		@img_url = @site.img_url
		@tw_card_type = 'summary'
		status 404
	else
		@title = "#{app.name} | #{@site.title}"
		@name = app.name
		@description = app.description
		@show_app_banner = true
		@url = "#{@site.url}/apps/#{app.slug}"
		@img_url = app.icon
		@ios_app_id = app.ios_app_id
		@tw_card_type = 'app'
		@icon = app.icon
		@tw_id = app.twitter
		@banner = app.banner
		@itunes = app.itunes
		@favicon = app.favicon
	end
	redirect @itunes
	#erb :apps
end

## End 45 Bit Pages ##

get '/twilio' do
	set_site
  account_sid = ENV['twilio_sid']
  auth_token = ENV['twilio_auth_token']
 
# set up a client to talk to the Twilio REST API 
@client = Twilio::REST::Client.new account_sid, auth_token 

@call = @client.account.calls.create({
	:to => '+18472128597', 
	:from => '+12249006281', 
	:url => 'http://45bitcode.com',  
	:method => 'GET',  
	:fallback_method => 'GET',  
	:status_callback_method => 'GET',    
	:record => 'false'
})

end

get '/call' do
puts 'calling me'
end

#Clicking on submit for Email
post '/email/?' do
  email = params[:email]
  name = params[:name]
  subject = params[:subject]
  message = params[:message]
  puts message
  redirect '/thankyou'
end

## Passbook Creation API ##
get '/api/passbook?' do
  type = params[:type]
  pass_path = [:serial]
  
  if type == 'business_card'
    @cert_path = ENV['passbook_business_card_cert_path']
    @cert_password = ENV['passbook_business_card_cert_password']
  end

  Dubai::Passbook.certificate, Dubai::Passbook.password = @cert_path, @cert_password 

  # Example.pass is a directory with files "pass.json", "icon.png" & "icon@2x.png"
  File.open("#{pass_path}.pkpass", 'w') do |f|
    f.write Dubai::Passbook::Pass.new('vincedavis.pass').pkpass.string
  end  

end

## Passbook Webservice Logic ##
get '/push/:serial_number' do
  APNS.instance.open_connection('production')
  puts 'Opening connection to APNS.'
	##{params[:serial_number]}
	# Get the list of registered devices and send a push notification
	#@push_tokens = @registrations.collect{|r| r[:push_token]}.uniq
	#@push_tokens.each do |push_token|
  query = "type=push&sernum=#{params[:serial_number]}"
	
  puts "#{query}"
 	
  #content_type "application/json"
  uri = URI::HTTP.build(
  :host  => HOST,
  :path  => '',
  :query => query
  )
  
  returnJson = JSON.parse(Net::HTTP.get(uri))
  statusId = returnJson['id']
  
  if statusId == '200'
  	returnJson.delete('id')
  	returnJson.delete('pass')
  	content_type :json
  	
  	returnJson['pushToken'].each do |pushToken|
  		#push_token = "e8b0277bca08843a733759d39b536c988c391288235862904bcac586a80fe115"
  		puts "Sending a notification to #{push_token}"
  		APNS.instance.deliver(push_token, '{}')
  		APNS.instance.close_connection
  		puts 'APNS connection closed.'
  	end
  	
  	response.body = returnJson.to_json
  
  	status 200
  end
  
  if statusId == '404'
  	# The device did not statisfy the authentication requirements
  	# Return a 401 NOT AUTHORIZED response
  	status 404
  end
  
	

end

# Registration
# register a device to receive push notifications for a pass
#
# POST /v1/devices/<deviceID>/registrations/<typeID>/<serial#>
# Header: Authorization: ApplePass <authenticationToken>
# JSON payload: { "pushToken" : <push token, which the server needs to send push notifications to this device> }
#
# Params definition
# :device_id      - the device's identifier
# :pass_type_id   - the bundle identifier for a class of passes, sometimes refered to as the pass topic, e.g. pass.com.apple.backtoschoolgift, registered with WWDR
# :serial_number  - the pass' serial number
# :pushToken      - the value needed for Apple Push Notification service
#
# server action: if the authentication token is correct, associate the given push token and device identifier with this pass
# server response:
# --> if registration succeeded: 201
# --> if this serial number was already registered for this device: 304
# --> if not authorized: 401
post '/v1/devices/:device_id/registrations/:pass_type_id/:serial_number' do
  puts 'Handling registration request...'
 	
  if request && request.body
    request.body.rewind
    json_body = JSON.parse(request.body.read)
    if json_body['pushToken']
      push_token =  json_body['pushToken']
    end
  end
  
  if env && env['HTTP_AUTHORIZATION']
    authentication_token = env['HTTP_AUTHORIZATION'].split(' ').last
  end
 	
 	puts "#<RegistrationRequest device_id: #{params[:device_id]}, pass_type_id: #{params[:pass_type_id]}, serial_number: #{params[:serial_number]}, authentication_token: #{authentication_token}, push_token: #{push_token}>"
 	
 	query = "type=post&id=#{params[:device_id]}&pass=#{params[:pass_type_id]}&sernum=#{params[:serial_number]}&token=#{authentication_token}&push=#{push_token}"
 	puts "#{query}"
  content_type 'application/json'
  uri = URI::HTTP.build(
  :host  => HOST,
  :path  => '',
  :query => query
  )
  
  puts uri
  
  returnJson = JSON.parse(Net::HTTP.get(uri))
  statusId = returnJson['id']
  
  if statusId == '201'
  	status 201
  end
  
  if statusId == '200'
  	# The device has already registered for updates on this pass
      # Acknowledge the request with a 200 OK response
      status 200
  end
  
  if statusId == '401'
  	# The device did not statisfy the authentication requirements
  	# Return a 401 NOT AUTHORIZED response
  	status 401
  end
  
end
 
 
# Updatable passes
#
# get all serial #s associated with a device for passes that need an update
# Optionally with a query limiter to scope the last update since
# 
# GET /v1/devices/<deviceID>/registrations/<typeID>
# GET /v1/devices/<deviceID>/registrations/<typeID>?passesUpdatedSince=<tag>
#
# server action: figure out which passes associated with this device have been modified since the supplied tag (if no tag provided, all associated serial #s)
# server response:
# --> if there are matching passes: 200, with JSON payload: { "lastUpdated" : <new tag>, "serialNumbers" : [ <array of serial #s> ] }
# --> if there are no matching passes: 204
# --> if unknown device identifier: 404
#
#
get '/v1/devices/:device_id/registrations/:pass_type_id?' do
  #puts "Handling updates request... pass_type_id: #{params[:pass_type_id]}"
  # Check first that the device has registered with the service
  
  query = ''
  
  if env && env['HTTP_AUTHORIZATION']
    authentication_token = env['HTTP_AUTHORIZATION'].split(' ').last
  end
  
  if params[:passesUpdatedSince] && params[:passesUpdatedSince] != ''
      query = "type=get&id=#{params[:device_id]}&pass=#{params[:pass_type_id]}&token=#{authentication_token}&updated=#{params[:passesUpdatedSince]}"
  else
      query = "type=get&id=#{params[:device_id]}&pass=#{params[:pass_type_id]}&token=#{authentication_token}"
  end
  
  #puts "#{query}"
  
  content_type 'application/json'
  uri = URI::HTTP.build(
  :host  => HOST,
  :path  => '',
  :query => query
  )
  
  returnJson = JSON.parse(Net::HTTP.get(uri))
  statusId = returnJson['id']
  
  if statusId == '200'
  	returnJson.delete('id')
  	returnJson.delete('pass')
  	content_type :json
  	response.body = returnJson.to_json
  	#returnJson["serialNumbers"].each do |num|
  	#	puts "serial #{num} !!!"
  	#end
  	#status 200
  end
  
  if statusId == '204'
  	# The device has already registered for updates on this pass
      # Acknowledge the request with a 200 OK response
      status 204
  end
  
  if statusId == '404'
  	# The device did not statisfy the authentication requirements
  	# Return a 401 NOT AUTHORIZED response
  	status 404
  end
  
end


# Unregister
#
# unregister a device to receive push notifications for a pass
# 
# DELETE /v1/devices/<deviceID>/registrations/<passTypeID>/<serial#>
# Header: Authorization: ApplePass <authenticationToken>
#
# server action: if the authentication token is correct, disassociate the device from this pass
# server response:
# --> if disassociation succeeded: 200
# --> if not authorized: 401
delete '/v1/devices/:device_id/registrations/:pass_type_id/:serial_number' do
  puts 'Handling unregistration request...'
  
  if env && env['HTTP_AUTHORIZATION']
    authentication_token = env['HTTP_AUTHORIZATION'].split(' ').last
  end
 	
 	query = "type=delete&id=#{params[:device_id]}&pass=#{params[:pass_type_id]}&sernum=#{params[:serial_number]}&token=#{authentication_token}"
 	puts '#{query}'
  content_type 'application/json'
  uri = URI::HTTP.build(
  :host  => HOST,
  :path  => '',
  :query => query
  )
  
  returnJson = JSON.parse(Net::HTTP.get(uri))
  statusId = returnJson['id']
  
  if statusId == '200'
  	# The device has been unregistered
      # Acknowledge the request with a 200 OK response
      status 200
  end
  
  if statusId == '401'
  	# The device did not statisfy the authentication requirements
  	# Return a 401 NOT AUTHORIZED response
  	status 401
  end
  
end


# Pass delivery
#
# GET /v1/passes/<typeID>/<serial#>
# Header: Authorization: ApplePass <authenticationToken>
#
# server response:
# --> if auth token is correct: 200, with pass data payload
# --> if auth token is incorrect: 401
#
get '/v1/passes/:pass_type_id/:serial_number' do
  puts 'Handling pass delivery request...'
  
  path = "http://pass_creator.s3.amazonaws.com/passes/#{params[:serial_number]}/pass.pkpass"
  
  if env && env['HTTP_AUTHORIZATION']
    authentication_token = env['HTTP_AUTHORIZATION'].split(' ').last
  end
 	
 	query = "type=pass&pass=#{params[:pass_type_id]}&sernum=#{params[:serial_number]}&token=#{authentication_token}"
 	
 	puts "#{query}"
  content_type 'application/json'
  uri = URI::HTTP.build(
  :host  => HOST,
  :path  => '',
  :query => query
  )
  
  returnJson = JSON.parse(Net::HTTP.get(uri))
  statusId = returnJson['id']
  
  if statusId == '200'
  	# The device has been unregistered
      # Acknowledge the request with a 200 OK response
      # Send the pass file
      redirect "http://pass_creator.s3.amazonaws.com/passes/#{params[:serial_number]}/pass.pkpass"
      #status 200
  end
  
  if statusId == '401'
  	# The device did not statisfy the authentication requirements
  	# Return a 401 NOT AUTHORIZED response
  	status 401
  end
  
  
end


# Logging/Debugging from the device
#
# log an error or unexpected server behavior, to help with server debugging
# POST /v1/log
# JSON payload: { "description" : <human-readable description of error> }
#
# server response: 200
#
post '/v1/log' do
  #if request && request.body
  #  request.body.rewind
  #  json_body = JSON.parse(request.body.read)
  #  File.open(File.dirname(File.expand_path(__FILE__)) + "/log/devices.log", "a") do |f|
  #    f.write "[#{Time.now}] #{json_body["description"]}\n"
  #  end
  #end
  status 200
    
end



require 'rubygems'
require 'sinatra'
require 'json'
require 'httparty'
require 'awesome_print'
require 'mongo'
require 'mongoid'
require 'json/ext' 
require './model/apps.rb'
require './env' if File.exists?('env.rb')

Mongoid.load!('mongoid.yml')

def set_defaults

	@facebook = 'https://www.facebook.com/vince.davis'
	@twitter = 'http://www.twitter.com/vincedavis'
	@instagram = 'http://instagram.com/vinceinsanepaint'
	@author = 'Vince Davis'
	@auther_link = 'http://www.twitter.com/vincedavis'
	@title = '45 Bit Code'
	@company = '45 Bit Code'
	@description = 'Making sure all your bits are covered'
	@show_app_banner = false
	@url = 'http://45bitcode.com'
	@type = 'website'
	@img_url = 'http://www.45bitcode.com/img/circle.jpg'
	@fb_id = '575749510'
	@ios_app_id = '951386307'
	@tw_card_type = 'summary'
	@email = 'support@45bitcode.com'
	@tw_id = '@45bitcode'
	@phone = '224-294-4567'
	@city_st_zip = 'Chicago, IL 60606'
end

get '/?' do
	set_defaults

	erb :index
end

get '/blank?' do
	set_defaults
	
	app = App.new
	app.name = params[:new]
	app.save
	
  	erb :blank
end

get '/contact?' do
	set_defaults
	
  	erb :contact
end

get '/apps/:slug' do
	set_defaults
	@name = ''
	
	app = App.where(slug: params[:slug]).first
	
	if app.nil?
		status 404
	else
		@name = app.name
		@description = app.description
		@show_app_banner = true
		@url = 'http://45bitcode.com'
		@img_url = app.icon
		@ios_app_id = app.ios_app_id
		@tw_card_type = 'app'
		@icon = app.icon
		@tw_id = app.twitter
		@banner = app.banner
		@itunes = app.itunes
	end
	
	erb :apps
end

get '/thankyou' do
	set_defaults
	
	erb :thankyou
end

#Clicking on submit for Email
post '/email/?' do
  email = params[:email]
  name = params[:name]
  subject = params[:subject]
  message = params[:message]
  puts message
  redirect "/thankyou"
end

not_found do
	set_defaults
	
	status 404
	erb :oops
end

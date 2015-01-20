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

Mongoid.load!('mongoid.yml')

def set_defaults

	site = Site.find('54bc278856696e176c000000')
	@site = site
	
	@facebook = site.facebook #'https://www.facebook.com/vince.davis'
	@twitter = site.twitter #'http://www.twitter.com/vincedavis'
	@tumblr = site.tumblr
	@instagram = site.instagram #'http://instagram.com/vinceinsanepaint'
	@author = site.author #'Vince Davis'
	@auther_link = site.author_link #'http://www.twitter.com/vincedavis'
	@title = site.title #'45 Bit Code'
	@company = site.company #'45 Bit Code'
	@description = site.description #'Making great apps 1 bit at a time'
	@show_app_banner = false
	@url = site.url #'http://45bitcode.com'
	@type = 'website'
	@img_url = site.img_url #'http://www.45bitcode.com/img/top/placeit-4.jpg'
	@fb_id = site.fb_admin #'575749510'
	@ios_app_id = ''
	@tw_card_type = 'summary'
	@email = site.email #'support@45bitcode.com'
	@tw_id = site.tw_id #'@45bitcode'
	@phone = site.phone #'224-294-4567'
	@city_st_zip = site.city_st_zip #'Chicago, IL 60606'
	@favicon = site.favicon
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
		@title = "#{@site.title} | #{app.name}"
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

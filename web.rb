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
puts '--------------------should set ---------------------'
	@facebook = 'https://www.facebook.com/vince.davis'
	@twitter = 'http://www.twitter.com/vincedavis'
	@instagram = 'http://instagram.com/vinceinsanepaint'
	@author = 'Vince Davis'
	@auther_link = 'http://www.twitter.com/vincedavis'
	@title = '45 Bit Code'
	@company = '45 Bit Code'
	@description = 'Making sure all your bits are covered'
	@show_app_banner = true
	@url = 'http://45bitcode.com'
	@type = 'website'
	@img_url = 'http://www.45bitcode.com/img/circle.jpg'
	@fb_id = '575749510'
	@ios_app_id = '951386307'
	@tw_card_type = 'app'
	@tw_id = '@vincedavis'
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

get '/apps/:slug' do
	set_defaults
	@name = ''
	
	app = App.where(slug: params[:slug]).first
	
	if app.nil?
		status 404
	else
		@name = app.name
	end
	
	erb :apps
end

not_found do
	set_defaults
	
	status 404
	erb :oops
end

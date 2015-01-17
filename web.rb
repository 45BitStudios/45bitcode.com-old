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

get '/?' do
	erb :index
end

get '/blank?' do
	app = App.new
	app.name = params[:new]
	app.save
	
  	erb :blank
end

get '/apps/:name' do
	@name = ''
	app = App.where(name: params[:name]).first
	
	if app.nil?
		status 404
	else
		@name = app.name
	end
	
	erb :apps
end

not_found do
  status 404
  erb :oops
end

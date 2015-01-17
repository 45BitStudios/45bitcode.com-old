require 'mongo'
require 'mongoid'
require 'json/ext' 

class Site

	include Mongoid::Document
	include Mongoid::Timestamps
	field :name, type: String
	field :title, type: String
	field :description, type: String 
	field :facebook, type: String 
	field :twitter, type: String 
	field :instagram, type: String 
	field :ios_app_id, type: String 
	field :email, type: String 
	field :author, type: String 
end
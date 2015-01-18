require 'mongo'
require 'mongoid'
require 'json/ext' 

class App

	include Mongoid::Document
	include Mongoid::Timestamps
	field :name, type: String
	field :slug, type: String
	field :description, type: String 
	field :facebook, type: String 
	field :twitter, type: String 
	field :instagram, type: String 
	field :ios_app_id, type: String 
	field :email, type: String 
	field :author, type: String 
	field :icon, type: String 
	field :version, type: String 
	field :banner, type: String 
	field :itunes, type: String 

end

class Screenshot

	include Mongoid::Document
	include Mongoid::Timestamps
	field :slug, type: String
	field :img_url, type: String

end
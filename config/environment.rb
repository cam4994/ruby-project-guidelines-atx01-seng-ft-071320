require "sinatra/activerecord"
require 'net/http'
require 'open-uri'
require 'json'
require 'bundler'
require 'tty-prompt'

Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')

prompt = TTY::Prompt.new

require_all 'lib'
require "sinatra/activerecord"
require 'net/http'
require 'open-uri'
require 'json'
require 'bundler'
require 'tty-prompt'
require 'colorize'
require 'colorized_string'

Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')

require_all 'lib'
PROMPT = TTY::Prompt.new

ActiveRecord::Base.logger = nil
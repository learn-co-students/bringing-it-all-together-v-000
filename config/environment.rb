require 'bundler'
Bundler.require

require_all 'lib'
require 'sqlite3'
require_relative '../lib/meta'
require 'pry'
require 'rake'

DB = {:conn => SQLite3::Database.new("db/metas.db")}

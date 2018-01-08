require 'bundler'
Bundler.require

require 'sqlite3'
require 'pry'
require 'rake'

require_all 'lib'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}

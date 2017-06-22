require 'sqlite3'
require 'pry'
require_relative '../lib/dog'

#DB = {:conn => SQLite3::Database.new("db/dogs.db")}
DB = {:conn => SQLite3::Database.new("db/dogs.sqlite")}

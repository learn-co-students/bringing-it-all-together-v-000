require 'sqlite3'
require_relative '../lib/dog'

#=> responsible for setting up and maintaining connection to application's database
DB = {:conn => SQLite3::Database.new("db/dogs.db")}

require 'sqlite3'   #requires the swlite3 gem
require_relative '../lib/dog' #requires the dog class

DB = {:conn => SQLite3::Database.new("db/dogs.db")}   #initializes the DB connection as a hash

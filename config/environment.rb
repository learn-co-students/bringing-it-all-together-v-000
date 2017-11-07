require 'sqlite3'
require_relative '../lib/dog'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}
# sets up and maintains the connection to the database

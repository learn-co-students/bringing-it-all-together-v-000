require 'sqlite3'
require 'pry'
require_relative '../lib/dog'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}

def x;exit!;end
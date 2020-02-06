#!/usr/local/bin/ ruby 


require 'sqlite3'
load "./lib/dog.rb"
DB = {:conn => SQLite3::Database.new("db/dogs.db")}

def reload!
  puts "reloading...\n\n\n"
  load './lib/dog.rb'
end

pry.start

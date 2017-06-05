require 'bundler'
Bundler.require(:default, :development, :debug, :test, :for_this_app)



require_relative '../lib/dog'



DB = {:conn => SQLite3::Database.new("db/dogs.db")}

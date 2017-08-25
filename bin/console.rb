#!/usr/local/bin/ruby -w

load "./config/environment.rb"

def reload!
  puts "reloading..."
  load "./config/environment.rb"
end

pry.start

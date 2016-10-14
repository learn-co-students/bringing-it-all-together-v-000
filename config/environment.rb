require 'sqlite3'
require_relative '../lib/dog'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}
DB[:conn].execute("DROP TABLE IF EXISTS dogs")

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS dogs(
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
  )
  SQL
DB[:conn].execute(sql)
DB[:conn].results_as_hash = true

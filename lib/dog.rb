class Dog

  attr_accessor :name, :breed, :id

def initialize(id: nil, name:, breed:)
  @name = name
  @breed = breed
end

def self.create_table
  sql =  <<-SQL
       CREATE TABLE IF NOT EXISTS dogs (
         id INTEGER PRIMARY KEY,
         name TEXT,
         breed TEXT
         )
         SQL
     DB[:conn].execute(sql)
end


def self.drop_table
  sql =  <<-SQL
     DROP TABLE IF  EXISTS dogs
       SQL
   DB[:conn].execute(sql)
end

def save
  sql =  <<-SQL
     DROP TABLE IF  EXISTS dogs
       SQL
   DB[:conn].execute(sql)
end


end

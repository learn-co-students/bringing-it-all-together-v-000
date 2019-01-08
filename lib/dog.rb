require 'pry'

class Dog
  
  attr_accessor :name, :breed, :id
  
  def initialize(row)  
    @name= row[:name]
    @breed= row[:breed]
    @id= row[:id]
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT)
      SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end
  
  def save
    
  end
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
    binding.pry
    self.new_from_db(row)
  end
  
  
  
  
end  
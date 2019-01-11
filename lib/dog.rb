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
  
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].last_insert_row_id
    self
  end

  def self.create(attr_hash)
    dog = Dog.new(name: attr_hash[:name], breed: attr_hash[:breed]).save
    dog
  end

  def self.find_by_id(num)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", num)[0]
    self.new(name: row[1], breed: row[2], id: row[0])
  end
  
  def self.find_or_create_by(hash)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    row = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]
    if !row.empty?
      self.new(name: row[1], breed: row[2], id: row[0])
    else
      self.save
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1" 
      
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first 
  end
  
  def update
  
  end
  
end  
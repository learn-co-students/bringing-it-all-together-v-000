require_relative"../config/environment.rb"
require'pry'
class Dog 
  attr_accessor :name, :breed 
  attr_reader :id 
  
  def initialize(name:, breed:, id: nil)
    @name = name 
    @breed = breed 
    @id = id
  end 
  
  def self.create_table
    self.drop_table
    sql = <<-SQL
      CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
   SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end 
  
  def save
    if self.id
      self.update
    else 
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end 
    self
  end 
  
  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
  end 
  
  def self.find_by_id(i)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?    
    SQL
    
    DB[:conn].execute(sql, i).map do |row|
      self.new_from_db(row)
    end.first
  end 
  
  def self.find_or_create_by(thing)
      sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL
      
      r = DB[:conn].execute(sql, thing[:name], thing[:breed])
      if r.flatten.empty?
        self.create(thing)
      else 
        self.find_by_name(thing[:name])
      end 
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE name = ?
    SQL
    
    row = DB[:conn].execute(sql, name)
    self.new_from_db(row.flatten)
  end 
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = self.new(id: id, name: name, breed: breed)
    new_dog
  end 
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
end 
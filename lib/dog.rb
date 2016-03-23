require_relative "../config/environment.rb"
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
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
  sql = <<-SQL
   DROP TABLE dogs
   SQL
    DB[:conn].execute(sql) 
 end
  def save
     sql = <<-SQL
     INSERT INTO dogs (name, breed)
     VALUES (?,?)
     SQL
     DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
 
   end
   def self.create(name:, breed:)
     dog = Dog.new(name: name, breed: breed)
     dog.save
     dog
   end
   def self.new_from_db(row)
    self.new(name: row[1],breed: row[2],id: row[0])
  end
    def self.find_by_id(id)
     sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql,id).map do |row|
      self.new_from_db(row)
    end.first
  end

   def self.find_by_name(name)
     sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
 
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end
 def self.find(name:, breed:)
     sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
 
    DB[:conn].execute(sql,name,breed).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    self.find(name: name, breed: breed) || self.create(name: name, breed: breed)
    
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql,name, breed, id)
  end


end
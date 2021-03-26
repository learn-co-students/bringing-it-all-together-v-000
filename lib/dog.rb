require 'pry'

class Dog 
  attr_accessor :name, :breed, :id
  
  def initialize(dog)
    @name = dog[:name]
    @breed = dog[:breed]
    @id = dog[:id]
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self
  end
  
  def self.create(dog)
    new_dog = self.new(dog)
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, new_dog.name, new_dog.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    new_dog.id = @id
    new_dog
  end
  
  def self.new_from_db(row)
    db_dog = {}
    db_dog[:id] = row[0]
    db_dog[:name] = row[1]
    db_dog[:breed] = row[2]
    self.new(db_dog)
  end
  
  def self.find_by_id(id)
    db_dog = {}
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?;
    SQL
    row = DB[:conn].execute(sql, id)
    db_dog[:id] = row[0][0]
    db_dog[:name] = row[0][1]
    db_dog[:breed] = row[0][2]
    new_dog = self.new(db_dog)
    new_dog
  end
  
  def self.find_or_create_by(dog)
    db_dog = {}
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    row = DB[:conn].execute(sql, dog[:name], dog[:breed])
    if !row.empty?
      db_dog[:id] = row[0][0]
      db_dog[:name] = row[0][1]
      db_dog[:breed] = row[0][2]
      new_dog = self.new(db_dog)
    else
      new_dog = self.create(dog)
    end
    new_dog
  end

  def self.find_by_name(name)
    db_dog = {}
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?;
    SQL
    row = DB[:conn].execute(sql, name)
    db_dog[:id] = row[0][0]
    db_dog[:name] = row[0][1]    
    db_dog[:breed] = row[0][2]
    new_dog = self.new(db_dog)
    new_dog
  end
  
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
end
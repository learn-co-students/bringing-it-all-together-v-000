require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

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
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed    
  end

  def self.new_from_db(row)
    dog = self.new({id: row[0], name: row[1], breed: row[2]})
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?;
    SQL

    row = DB[:conn].execute(sql, name)
    new_from_db(row)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
      SQL
  
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]      
    end
    self
  end

  def self.create(id:nil, name:, breed:)
    dog = self.new(id: id, name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
    new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?;
    SQL

    array = DB[:conn].execute(sql, name, breed)
    if !array.empty?
      row = array[0]
      dog = self.new_from_db(row)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?;
    SQL

    row = DB[:conn].execute(sql, name).flatten
    dog = new_from_db(row)
  end
end
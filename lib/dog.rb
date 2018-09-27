require "pry"

class Dog
  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def self.new_from_db(row)
    id=row[0]
    name=row[1]
    breed=row[2]
    hash={:name => name, :breed => breed, :id => id}
    dog = Dog.create(hash)
  end

  def save
    sql_check = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    exists = DB[:conn].execute(sql_check, self.name, self.breed).flatten

    if !exists.empty?
      self
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
      self.id = id
      self
    end

  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
    Dog.new_from_db(dog)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    result = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
    if result
      dog = Dog.new_from_db(result)
    else
      dog = Dog.create(hash)
    end
    dog
  end

  def self.find_by_name(name)
    dog=DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
    Dog.new_from_db(dog)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

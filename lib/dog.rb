require 'pry'
class Dog
  attr_accessor :name, :breed, :id

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
    # if self.id
    #   self.update
    # else
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    # end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    found_dog = DB[:conn].execute(sql, id)[0]
    Dog.new(id: found_dog[0], name: found_dog[1], breed: found_dog[2])
  end


  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end

  def self.find_or_create_by(name: name, breed: breed)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed= ?
    SQL
    found_dog = DB[:conn].execute(sql, name, breed)[0]
    if found_dog
      new_dog = self.new_from_db(found_dog)
    else
      new_dog = self.create(name: name, breed:breed)
    end

  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1;
    SQL
    found_dog = DB[:conn].execute(sql, name)[0]
    self.new_from_db(found_dog)
  end

  def update
   sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
   SQL
   DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end

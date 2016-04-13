require 'pry'
class Dog

attr_accessor :name, :breed, :id

  def initialize(name: name, breed: breed, id: id = nil)
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
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs
      (name, breed)
      VALUES
      (?,?);
    SQL
    DB[:conn].execute(sql, self.name ,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end

  def self.create(name: name, breed: breed, id: id)
    dog = self.new(name: name, breed: breed, id: id = nil)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?;
    SQL
    dog = DB[:conn].execute(sql, id)[0]
    dog = Dog.new(name: dog[1], breed: dog[2], id: dog[0])
    dog
  end

  def self.find_or_create_by(name: name, breed: breed, id: id)
    dog_attributes = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog_attributes.empty?
      dog = Dog.new(name: dog_attributes[0][1], breed: dog_attributes[0][2], id: dog_attributes[0][0])
    else
      dog = self.create(name: name, breed: breed, id: id)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?;
    SQL
    dog = DB[:conn].execute(sql, name)[0]
    dog = Dog.new(name: dog[1], breed: dog[2], id: dog[0])
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?;
    SQL
    dog = DB[:conn].execute(sql, self.name, self.breed, self.id)
    dog = Dog.new(name: dog[1], breed: dog[2], id: dog[0])
    dog
  end
end

require 'pry'
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
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    dog.save
    dog
  end

  def self.find_by_id(id)
    dog_lkp = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    if !dog_lkp.empty?
      dog_data = dog_lkp[0]
      dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
      dog
    end
  end

  def self.find_or_create_by(name:, breed:)
    dog_lkp = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog_lkp.empty?
      dog_data = dog_lkp[0]
      dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
    else
      dog = Dog.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    dog_lkp = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
    if !dog_lkp.empty?
      dog_data = dog_lkp[0]
      dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
      dog
    end
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", @name, @breed, @id)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs
      VALUES(?,?,?)
    SQL

    DB[:conn].execute(sql, @id, @name, @breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

end

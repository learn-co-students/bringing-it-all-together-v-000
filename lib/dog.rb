require 'pry'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |k,v|
          instance_variable_set("@#{k}",v) unless v.nil?
    end
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
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    self
  end

  def self.create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, id).first
    new_from_db(result)
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_info = dog[0]
      new_dog = new_from_db(dog_info)
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name).first
    new_from_db(result)
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

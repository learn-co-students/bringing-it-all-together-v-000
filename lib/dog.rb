require 'pry'
class Dog

  attr_accessor :name, :breed, :id
  def initialize(name: nil, breed: nil, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
          )
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
    self
  end

  def self.create(hash_of_attributes)
    dog = Dog.new
    hash_of_attributes.each do |attribute, value|
        dog.send("#{attribute}=", value)
    end
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
          SELECT * FROM dogs
          WHERE id = ?
          SQL
    row = DB[:conn].execute(sql, id).first
    Dog.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
          SELECT * FROM dogs
          WHERE name = ? AND breed = ?
          SQL
    row = DB[:conn].execute(sql, name, breed)[0]
    if row != nil
      Dog.new_from_db(row)
    else
      Dog.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
          SELECT * FROM dogs
          WHERE name = ?
          SQL
    row = DB[:conn].execute(sql, name).first
    Dog.new_from_db(row)
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def update
    sql = <<-SQL
          UPDATE dogs SET name = ?, breed = ?
          WHERE id = ?
          SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
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
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
          SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(hash)
    Dog.new(name:hash[:name], breed:hash[:breed]).tap { |i|
      i.save
    }
  end

  def self.find_by_id(id)
    sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?;
          SQL
    record = DB[:conn].execute(sql, id).flatten
    Dog.new(id:record[0], name:record[1], breed:record[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
          SQL
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2])
    else
      dog = self.create(name:name, breed:breed)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?;
          SQL
    record = DB[:conn].execute(sql, name).flatten
    Dog.new_from_db(record)
  end

  def update
    sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
          SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

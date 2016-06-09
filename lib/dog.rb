require_relative '../config/environment.rb'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
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
            DROP TABLE IF EXISTS dogs
          SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
              INSERT INTO dogs (name, breed)
              VALUES (?, ?)
            SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0].first
    end
    self
  end

  def update
    sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
          SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_id(id)
    sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
          SQL

    dog = DB[:conn].execute(sql, id).map do |dog|
      self.new_from_db(dog)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
          SQL

    DB[:conn].execute(sql, name).map do |dog|
      self.new_from_db(dog)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
            LIMIT 1
          SQL

    dog = DB[:conn].execute(sql, name, breed)
    if dog.empty?
      dog = self.create(name: name, breed: breed)
    else
      curr_dog = dog.first
      dog = self.new(id: curr_dog[0], name: curr_dog[1], breed: curr_dog[2])
    end
    dog
  end

end
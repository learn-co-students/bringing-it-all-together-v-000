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
      CREATE TABLE IF NOT EXISTS dogs;
    SQL

    #DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    new_dog = {:id => row[0],
               :name => row[1],
               :breed => row[2]}
    self.new(new_dog)
    #binding.pry
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    dog = DB[:conn].execute(sql, name)[0]
    new_dog = self.new_from_db(dog)
    #binding.pry
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, @name, @breed)
      sql = <<-SQL
        SELECT last_insert_rowid() FROM dogs
      SQL
      @id =DB[:conn].execute(sql)[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @id)
    #binding.pry
    self
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    new_dog = DB[:conn].execute(sql, id)[0]
    dog = self.new_from_db(new_dog)
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    new_dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    new_dog.flatten!
    #binding.pry
    if !new_dog.empty?
      #binding.pry
      self.new_from_db(new_dog)
    else
      dog = self.create(hash)
      dog
    end

  end
end

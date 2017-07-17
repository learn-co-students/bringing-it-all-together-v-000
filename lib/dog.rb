require 'pry'

class Dog

  attr_reader :id
  attr_accessor :name, :breed

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
          breed TEXT);
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
    if @id
      sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?;
            SQL
      DB[:conn].execute(sql, @name, @breed, @id)
      self
    else
      sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (?,?);
            SQL
      DB[:conn].execute(sql, @name, @breed)
      sql_for_id = <<-SQL
                    SELECT id
                    FROM dogs
                    WHERE name = ? AND breed = ?;
                    SQL
      @id = DB[:conn].execute(sql_for_id, @name, @breed).flatten[0]
      self
    end
  end

  def self.create(attributes)
    dog = self.new(name: nil, breed: nil)
    attributes.each do |k,v|
      dog.send("#{k}=",v)
    end
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE id = ?;
          SQL
    dog_row = DB[:conn].execute(sql, id).flatten
    dog = self.new(name: dog_row[1], breed: dog_row[2], id: dog_row[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ? AND breed = ?;
          SQL
    dog_row = DB[:conn].execute(sql, name, breed).flatten
    
    if dog_row != []
      self.new(name: dog_row[1], breed: dog_row[2], id: dog_row[0])
    else
      dog = self.new(name: name, breed: breed)
      dog.save
    end
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?;
          SQL
    dog_row = DB[:conn].execute(sql, name).flatten
    self.new_from_db(dog_row)
  end

  def update
    #update
    # This spec will create and insert a dog, and after, it will change the name 
    # of the dog instance and call update. The expectations are that after this 
    # operation, there is no dog left in the database with the old name. If we query 
    # the database for a dog with the new name, we should find that dog and the ID 
    # of that dog should be the same as the original, signifying this is the same 
    # dog, they just changed their name.

    sql = <<-SQL
          UPDATE dogs
          SET name = ?
          WHERE id = ?;
          SQL
    DB[:conn].execute(sql, self.name, self.id)
  end
end
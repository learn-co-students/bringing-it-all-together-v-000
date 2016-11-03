require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(id:nil, name:"", breed:"")
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
        DROP TABLE IF EXISTS dogs
      SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1;
      SQL

    data = DB[:conn].execute(sql, name)[0]

    self.new(id: data[0], name: data[1], breed: data[2])
  end

  def save
    sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?);
      SQL

    DB[:conn].execute(sql, @name, @breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:"", breed:"")
    dog = self.new()
    dog.name = name
    dog.breed = breed
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?;
      SQL

    data = DB[:conn].execute(sql, id)[0]

    self.new(id: data[0], name: data[1], breed: data[2])
  end

  def update
    sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
      SQL

    DB[:conn].execute(sql, @name, @breed)
  end

  def self.find_or_create_by(name:"", breed:"")
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?",name,breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.new({id:dog_data[0], name:dog_data[1], breed:dog_data[2]})
    else
      dog = self.create({name:name, breed:breed})
    end
    dog
  end

end

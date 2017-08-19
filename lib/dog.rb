require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs;")
  end

  def save
    if self.id
      sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?;
      SQL

      DB[:conn].execute(sql, name, breed, id)
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, name, breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = new(name:name, breed:breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?;
    SQL

    arr = DB[:conn].execute(sql, id).first

    new_from_db(arr)
  end

  def self.find_or_create_by(name:, breed:)
    data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed).first

    if data
      new_from_db(data)
    else
      create(name:name, breed:breed)
    end
  end

  def self.new_from_db(row)
    new(id:row[0],name:row[1],breed:row[2])
  end

  def self.find_by_name(name)
    data = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first

    if data
      new_from_db(data)
    else
      puts 'DNE'
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, name, breed, id)
  end

end

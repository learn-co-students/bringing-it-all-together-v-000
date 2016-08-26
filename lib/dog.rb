require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS "#{self.table_name}" (
      id INTEGER PRIMARY KEY, 
      name TEXT,
      breed TEXT
      )
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO "#{self.class.table_name}" (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * 
    FROM "#{self.table_name}"
    WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)
    self.new_from_db(row.first)
  end

  def self.find_or_create_by(name:, breed:)
    if 
      sql =<<-SQL
        SELECT * 
        FROM "#{self.table_name}"
        WHERE name = ? 
        AND breed = ?
      SQL
      found_dog = DB[:conn].execute(sql, name, breed)
      if found_dog.empty?
        dog = self.create(name: name, breed: breed)
      else
        dog = self.new(id: found_dog[0][0], name: found_dog[0][1], breed: found_dog[0][2])
      end
    dog
    end
  end

  def self.find_by_name(name)
    sql =<<-SQL
    SELECT *
    FROM "#{self.table_name}"
    WHERE name = ?
    LIMIT 1
    SQL

    row = DB[:conn].execute(sql, name)
    self.new_from_db(row.first)
  end

  def self.new_from_db(row)
   self.new(name: row[1], breed: row[2], id: row[0])
  end
end 
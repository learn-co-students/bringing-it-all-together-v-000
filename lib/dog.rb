require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def self.create_table
    sql =
      <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =
      <<-SQL
        DROP TABLE dogs
      SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    attributes = {id: row[0], name: row[1], breed: row[2]}
    self.new(attributes)
  end

  def self.find_or_create_by(attributes)
    sql =
      <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ? AND breed = ?
      SQL
    row_array = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
    if !row_array.empty?
      row = row_array[0]
      attributes = {id: row[0], name: row[1], breed: row[2]}
      self.new(attributes)
    else
      create(attributes)
    end
  end

  def self.create(attributes)
    creation = self.new(attributes)
    creation.save
    creation
  end

  def self.find_by_id(id)
    sql =
      <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
      SQL
      row = DB[:conn].execute(sql, id)[0]
      attributes = {id: row[0], name: row[1], breed: row[2]}
      self.new(attributes)
  end

  def self.find_by_name(name)
    sql =
      <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
      SQL
      row = DB[:conn].execute(sql, name)[0]
      attributes = {id: row[0], name: row[1], breed: row[2]}
      self.new(attributes)
  end

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def save
    if id
      update
    else
      sql =
        <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql =
      <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
      SQL
    DB[:conn].execute(sql, name, breed, id)
  end

end

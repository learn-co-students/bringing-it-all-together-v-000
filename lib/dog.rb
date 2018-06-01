require "pry"
class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
    #binding.pry
  end
  #binding.pry

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
    sql = <<-SQL
      DROP TABLE dogs
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
      result = DB[:conn].execute("SELECT * FROM dogs").first
      self.id = result[0]
      self
    end
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    #binding.pry
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.new_from_db(row)
    dog = self.new({id: row[0], name: row[1], breed: row[2]})
  end

  def self.find_or_create_by(attributes)
    #binding.pry
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
    if !dog.empty?
      dog_data = dog
      dog = self.new_from_db([dog_data[0], dog_data[1], dog_data[2]])
    else
      dog = self.create(attributes)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end


end

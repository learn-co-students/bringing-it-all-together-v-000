require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id; @name = name; @breed = breed
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
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?);
    SQL

    self.tap do |dog|
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def self.create(hash)
    self.new(hash).tap do |dog|
      hash.each { |key, value| dog.send("#{key}=", value) }
      dog.save
    end
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    row = DB[:conn].execute(sql, id).first
    self.new(id: id, name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      dog = dog.first
      dog = self.new(id: dog[0], name: dog[1], breed: dog[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? LIMIT 1;
      SQL

    self.new_from_db(DB[:conn].execute(sql, name).first)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?;
    SQL

    self.tap { |dog| DB[:conn].execute(sql, self.name, self.breed, self.id) }
  end

end

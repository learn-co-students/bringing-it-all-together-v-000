class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    self.name, self.breed, self.id = name, breed, id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      update
      return self
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT MAX(id) FROM dogs")[0][0]
      return self
    end
  end

  def self.create(name:, breed:, id: nil)
    dog = self.new(name: name, breed: breed, id: id)
    dog.save
  end

  def self.new_from_db(row)
    self.create(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    row = DB[:conn].execute(sql, name, breed)[0]

    if row
      self.new_from_db(row)
    else
      self.create(name: name, breed: breed)
    end
  end

end

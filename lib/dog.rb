class Dog
  attr_accessor :id, :name, :breed

  def initialize (id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
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
    DROP TABLE dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(attributes)
    self.new(attributes).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?;
    SQL
    dog = DB[:conn].execute(sql, id).flatten
    id = dog[0]
    name = dog[1]
    breed = dog[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?;
    SQL
    dog = DB[:conn].execute(sql, name).flatten
    id = dog[0]
    name = dog[1]
    breed = dog[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?;
    SQL
    dog = DB[:conn].execute(sql, name, breed).flatten

    if dog.empty?
      self.create(name: name, breed: breed)
    else
      self.new_from_db(dog)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].last_insert_row_id
      self
    end
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs
        (id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def self.new_from_db(row)
    return nil if row[0].nil?
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name)
    self.new_from_db(result[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def save
    if Dog.find_by_id(@id).nil?
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", @name, @breed)
    end
      dog = Dog.find_or_create_by(name: @name, breed: @breed)
      @id = dog.id
      dog
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id).flatten
    Dog.new_from_db(row)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    result = DB[:conn].execute(sql, name, breed)
    if !result.empty?
      return Dog.new_from_db(result[0])
    else
      Dog.create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name).flatten
    Dog.new_from_db(row)
  end
end

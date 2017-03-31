class Dog
  #attribute and variables
  attr_accessor :id, :name, :breed


  #initialize
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  #class methods
  def self.create_table
    sql = <<-sql
      CREATE TABLE
      IF NOT EXISTS
      dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    sql

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-sql
      DROP TABLE
      dogs;
    sql

    DB[:conn].execute(sql)
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-sql
      SELECT *
      FROM dogs
      WHERE id = ?;
    sql

    DB[:conn].execute(sql, id).map{|row| self.new_from_db(row)}.first
  end

  def self.find_by_name(name)
    sql = <<-sql
      SELECT *
      FROM dogs
      WHERE name = ?;
    sql

    DB[:conn].execute(sql, name).map{|row| self.new_from_db(row)}.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-sql
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    sql

    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      new_dog = self.new_from_db(dog.first)
    else
      new_dog = self.create(name: name, breed: breed)
    end
  end

  #instance methods
  def save
    sql = <<-sql
      INSERT INTO
      dogs
      (name, breed)
      values
      (?,?);
    sql

    id_pull = <<-sql
      SELECT
      last_insert_rowid()
      FROM
      dogs;
    sql

    if self.id
      self.update
    else
      DB[:conn].execute(sql, self.name, self.breed)

      self.id = DB[:conn].execute(id_pull)[0][0]
    end
    self
  end

  def update
    sql = <<-sql
      UPDATE
      dogs
      SET
      name = ?, breed = ?
      WHERE
      id = ?;
    sql

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



end

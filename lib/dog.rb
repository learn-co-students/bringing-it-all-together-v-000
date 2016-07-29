class Dog
require'pry'

attr_accessor :name, :breed
attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT);
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
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(num)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    new_dog = DB[:conn].execute(sql, num)[0]
    self.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
  end

  # def self.find_or_create_by(name:, breed:)
  #   if Dog.id
  #     sql = <<-SQL
  #       SELECT * FROM dogs
  #       WHERE name = ?, breed = ?
  #     SQL

  #     DB[:conn].execute(sql, name, breed)
  #   else
  #     #create
  #     puts "create"
  #   end
  # end

  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])

  end

  def self.find_by_name(dog_name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL

    new_dog = DB[:conn].execute(sql, dog_name)[0]
    self.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
  end

  def update

  end







end
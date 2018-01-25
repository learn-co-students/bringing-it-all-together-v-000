require_relative "../config/environment.rb"

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
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
    DB[:conn].execute("DROP TABLE dogs;")
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed )
    new_dog.save
    new_dog
  end

   def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    self.new_from_db(DB[:conn].execute(sql,id)[0])
  end

  def self.find_or_create_by(x)
    sql = "SELECT id FROM dogs WHERE name = ? AND breed = ?"
    id = DB[:conn].execute(sql, x[:name], x[:breed])
    id != [] ? self.find_by_id(id[0][0]) :  self.create(x)
  end

  def self.new_from_db(row)
    new_dog = self.new(row[1], row[2], row[0])
    new_dog
  end

  def self.new_from_db(array)
    new_dog = Dog.new({id: array[0], name: array[1], breed: array[2]})
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

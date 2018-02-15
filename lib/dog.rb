require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  #---------Instance Methods-----------
  def save
    if id
      update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
      DB[:conn].execute(sql, name, breed)
      self.id = DB[:conn].execute('SELECT last_insert_rowid()')[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  #-----------Class Methods-----------
  class << self
    def create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name INTEGER,
        breed INTEGER)
      SQL
      DB[:conn].execute(sql)
    end

    def drop_table
      DB[:conn].execute('DROP TABLE IF EXISTS dogs')
    end

    def create(dog)
      Dog.new(dog).save
    end

    def find_by_id(id)
      sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
      SQL
      dog = DB[:conn].execute(sql, id)[0][0]
      Dog.new(id: dog[0], name: dog[1], breed: dog[2])
    end

    def find_or_create_by(pet)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", pet[:name], pet[:breed])
      if !dog.empty?
        existing_dog = dog[0]
        dog = Dog.new(id: existing_dog[0], name: existing_dog[1], breed: existing_dog[2])
      else
      dog = Dog.new(name: pet[:name], breed: pet[:breed]).save
      end
      dog
    end

    def new_from_db(row)
      Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def find_by_name(name)
      sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        LIMIT 1
      SQL
      new_from_db(DB[:conn].execute(sql, name)[0])
    end
  end
end

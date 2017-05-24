require 'pry'
class Dog
  attr_accessor :id, :name, :breed

  def initialize(name: name, breed: breed, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self::create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self::drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self::new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end

  def self::find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name =?", name).flatten
    self.new_from_db(dog)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self::create(name: name, breed: breed, id: id)
    dog = self.new(name: name, breed: breed, id: id)
    dog.save
  end

  def self::find_by_id(id_num)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE id =?", id_num).flatten
    self.new_from_db(dog)
  end

  def self::find_or_create_by(name:, breed:)
    dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
    if !dog_row.empty?
      self.new_from_db(dog_row)
    else
      dog = self.create(name: name, breed: breed)
    end
  end

end

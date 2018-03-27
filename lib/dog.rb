class Dog

  attr_accessor :id, :name, :breed

  def initialize(dog_hash)
    dog_hash.each {|key, value| self.send("#{key}=", value)}
  end

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
    sql = "DROP TABLE IF EXISTS dogs"
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

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    dog_hash = {:name => name, :breed => breed}
    dog = Dog.new(dog_hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    dog_array = DB[:conn].execute(sql, id).flatten
    dog = Dog.new(dog_array_to_hash(dog_array))
    dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, name, breed).flatten

    if !dog.empty?
      dog = Dog.new(dog_array_to_hash(dog))
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.dog_array_to_hash(dog_array)
    dog_hash = {:id => dog_array[0], :name => dog_array[1], :breed => dog_array[2]}
    dog_hash
  end

  def self.new_from_db(dog_array)
    Dog.new(dog_array_to_hash(dog_array))
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

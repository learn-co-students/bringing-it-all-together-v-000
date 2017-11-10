class Dog

  attr_accessor :name, :breed
  attr_reader :id

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
        INSERT INTO dogs
        (name, breed)
        VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
   dog = Dog.new(name: name, breed: breed)
   dog.save
 end

 def self.new_from_db(row_array)
   Dog.new(id: row_array[0], name: row_array[1], breed: row_array[2])
 end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      SQL
    row_array = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row_array)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE  name = ? AND breed = ?
      SQL
    dog_row = DB[:conn].execute(sql, name, breed)

    if dog_row.empty?
      dog = self.create(name: name, breed: breed)
    else
      dog_data = dog_row[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      SQL
    row_array = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row_array)
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

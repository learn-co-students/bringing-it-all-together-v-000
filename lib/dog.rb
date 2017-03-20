class Dog
  attr_accessor :name, :breed, :id

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
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM DOGS
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).map do |row|
      Dog.new_from_db(row)
    end.first
  end

  def self.new_from_db(row)
    id, name, breed = row[0], row[1], row[2]
    Dog.new(id: id, name: name, breed: breed)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM DOGS WHERE name = '#{name}' AND breed = '#{breed}'")
    if !dog.empty?
      attributes = dog[0]
      dog = Dog.new(id: attributes[0], name: attributes[1], breed: attributes[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM DOGS
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map do |row|
      Dog.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

class Dog
  attr_accessor :name, :breed, :id

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
      breed TEXT
    )
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
    INSERT INTO dogs
    VALUES (?, ?, ?)
    SQL

    DB[:conn].execute(sql, self.id, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self

  end

  def self.create(name:, breed:)
    dog = Dog.new(name:name, breed:breed)
    dog.save
    dog

  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    DB[:conn].execute(sql,id).map do |row|
      Dog.new(id:row[0], name:row[1], breed:row[2])
    end.first
  end

  def self.find_or_create_by(name:, breed:)

    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = "#{name}" AND breed = "#{breed}"
    SQL
      dog = DB[:conn].execute(sql)
    if !dog.empty?
      dog_data = dog[0]
       Dog.new(id: dog_data[0], name:dog_data[1], breed:dog_data[2])
    else
      self.create(name:name, breed:breed)
    end
  end

  def self.new_from_db(row)

      Dog.new(id:row[0], name:row[1], breed:row[2])
    
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map do |row|
      Dog.new(id:row[0], name:row[1], breed:row[2])
    end.first
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    SQL
    DB[:conn].execute(sql, name, breed)
  end
end

class Dog
  attr_accessor :id, :name, :breed


  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY key,
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
    INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute( "SELECT last_insert_rowid() FROM dogs")[0][0]
  end

  def self.create(id, name, breed)
    dog = Dog.new(id, name, breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(name, breed)
  end
end

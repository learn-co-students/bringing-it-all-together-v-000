class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id, @name, @breed = id, name, breed
  end # initalize

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end # create_table

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end # drop_table

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT LAST_INSERT_ROWID() FROM dogs")[0][0]
    self
  end # save

  def self.create(name:, breed:)
    Dog.new(name: name, breed: breed).save
  end # create

  def self.find_by_id(id)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE ID = ?", id).flatten
    new_from_db(dog)
  end # find_by_id

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs where name = ? and breed = ?", name, breed)

    if !dog.empty?
      new_from_db(dog[0])
    else
      create(name: name, breed: breed)
    end
  end # find_or_create_by

  def self.new_from_db(array)
    dog = Dog.new(id: array[0], name: array[1], breed: array[2])
  end # new_from_db

end

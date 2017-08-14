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

  def self.new_from_db(array)
    dog = Dog.new(id: array[0], name: array[1], breed: array[2])
  end # new_from_db

  def save
  end # save

end

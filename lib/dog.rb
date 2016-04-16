class Dog

  # has a name and a breed
  attr_accessor :id, :name, :breed

  # has an id that defaults to `nil` on initialization
  # accepts key value pairs as arguments to initialize
  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  # creates the dogs table in the database
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

  # drops the dogs table from the database
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  # saves an instance of the dog class to the database
  # and then sets the given dogs `id` attribute
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
  end

end

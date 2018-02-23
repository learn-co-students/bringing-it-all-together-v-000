class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    self.name = name
    self.id = id
    self.breed = breed
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
    DB[:conn].execute('DROP TABLE dogs')
  end

  def self.new_from_db(id, name, breed)
    new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL

    id, name, breed = DB[:conn].execute(sql, name)[0]
    self.new_from_db(id, name, breed)
  end
end

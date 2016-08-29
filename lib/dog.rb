class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
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

  def self.new_from_db(row)
    dog = self.new
    dog.id = row[0]
    dog.name = row[1]
    dog.breed = row[2]
    dog
  end

  def self.find_by_name
    
  end
end

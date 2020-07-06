class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name, @breed, @id = name, breed, id
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


end

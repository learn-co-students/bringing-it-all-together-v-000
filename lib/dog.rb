require 'pry'

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id = nil, hash)
      @id = id
      @name = hash[:name]
      @breed =hash[:breed]
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

  def update

end

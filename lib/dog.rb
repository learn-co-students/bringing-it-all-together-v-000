require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id = nil, dog)
    @id = id
    @name = dog[:name]
    @breed = dog[:breed]
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

  end

end

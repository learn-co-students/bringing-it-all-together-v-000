require_relative "../config/environment.rb"

class Dog

  attr_accessor :id, :name, :breed
  @@all = []

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
    @@all << self
  end

  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS #{self.table_name} (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      update
    else
    sql = <<-SQL
      INSERT INTO #{self.table_name} (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name}")[0][0]
    end
    #binding.pry
    self
  end

  def update()
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(id: nil,name:, breed:)
    @name = name
    @breed = breed
    @id =id
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
      sql = "DROP TABLE IF EXISTS dogs"
      DB[:conn].execute(sql)
    end
    def save
      if self.id == nil
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
      else
        sql = <<-SQL
          UPDATE dogs SET name = ?, breed = ?
        SQL
      end
      DB[:conn].execute(sql, self.name, self.breed)
      if @id != nil
        @id
      else
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end
    def self.create(hash)
      dog = Dog.new(hash)
      dog.save
    end

    def self.find_by_id(id)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
      SQL

      DB[:conn].execute(sql, id).map do |row|

        self.new_from_db(row)
      end.first
    end

    def self.new_from_array(row)
      hash = {:id => row[0], :name => row[1], :breed => row[2]}
      dog = Dog.new(hash)
      dog
    end
    def self.new_from_db(row)
      dog = self.new_from_array(row)
      dog
    end
    def self.find_or_create_by(name:, breed:)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ? AND breed = ?
      SQL

      search = DB[:conn].execute(sql, name, breed)
      if search.empty?
        hash = {:name =>name, :breed => breed}
        dog = Dog.create(hash)
      else
        dog = self.new_from_array(search.flatten)

      end

      dog
    end

    def self.find_by_name(name)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
      SQL

      DB[:conn].execute(sql, name).map do |row|

        self.new_from_db(row)
      end.first
    end

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  end

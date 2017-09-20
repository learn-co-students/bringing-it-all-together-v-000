require_relative "../config/environment.rb"

class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
    end

    def self.new_from_db(row)
      new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
      new_dog
    end

    def self.create(attributes)
      dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
      dog.save
      dog
    end

    def self.find_or_create_by(attributes)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
      if !dog.empty?
        dog_data = dog[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else
      dog = self.create(name: attributes[:name], breed: attributes[:breed])
      end
    dog
    end


    def self.all
      sql = <<-SQL
        SELECT *
        FROM dogs
      SQL

      DB[:conn].execute(sql).map do |row|
        self.new_from_db(row)
      end
    end

    def self.find_by_id(id)
      sql = "SELECT * FROM dogs WHERE id = ?"
      result = DB[:conn].execute(sql, id)[0]
      Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ?"
      result = DB[:conn].execute(sql, name)[0]
      Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def save
      if self.id
        self.update
        self
      else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
      end
    end

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
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


end

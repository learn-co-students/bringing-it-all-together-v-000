require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
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
      DB[:conn].execute("DROP TABLE dogs")
    end

    def save
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)

      dog = Dog.new(hash)
      dog.save

    end

    def self.find_by_id(id)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = id")[0]

      hash = {}
      hash[:id] = dog[0]
      hash[:name] = dog[1]
      hash[:breed] = dog[2]
      Dog.new(hash)
    end

    def self.find_or_create_by(hash)

      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
      hashed = {}
      if !dog.empty?
        hashed[:id] = dog[0][0]
        hashed[:name] = dog[0][1]
        hashed[:breed] = dog[0][2]
        Dog.new(hashed)
      else
        Dog.create(hash)
      end
    end

    def self.new_from_db(row)
      hash = {}
      hash[:id] = row[0]
      hash[:name] = row[1]
      hash[:breed] = row[2]
      Dog.new(hash)
    end

    def self.find_by_name(name)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)
      hash = {}
      hash[:id] = dog[0][0]
      hash[:name] = dog[0][1]
      hash[:breed] = dog[0][2]
      test = Dog.new(hash)
    end

    def update
      sql = "UPDATE dogs SET name = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.id)

    end









end

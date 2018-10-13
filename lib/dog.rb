require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, id: nil, breed:)
    @name = name
    @id = id
    @breed = breed
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
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
      if self.id
        self.update
      else
        sql = <<-SQL
          INSERT INTO dogs(name, breed)
          VALUES (?, ?)
          SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end

    def self.create(attr)
      dog = Dog.new(attr)
      attr.each {|key, value| dog.send(("#{key}="), value)}
      dog.save

    end

    def self.find_by_id(id)
      sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL
      x = DB[:conn].execute(sql, id)[0]
      dog = self.new_from_db(x)
      dog
    end

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

      if !dog.empty?
        data = dog[0]
        new_dog = Dog.new(name: data[1], id: data[0], breed: data[2])
      else
        new_dog = Dog.create(name: name, breed: breed)
      end
      new_dog
    end

    def self.find_by_name(name)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).map do |row|
        self.new_from_db(row)
      end.first
    end
end

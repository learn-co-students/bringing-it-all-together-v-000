require_relative "../config/environment.rb"

class Dog
  attr_accessor :id, :name, :breed

  def initialize(id:nil, name:, breed:)
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
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
      if self.id
        self.update
      else
      sql = <<-SQL
      INSERT INTO dogs(name, breed) values (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
    end
    self
    end

    def self.create(name:, breed:)
      new_dog = self.new(name: name, breed:breed)
      new_dog.save
    #  new_dog
    end

    def self.find_by_id(id)
      sql = "SELECT * from dogs where id=? limit 1"
      DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
      end.first
    end

    def update
      sql = "UPDATE dogs set name = ?, breed= ? where id= ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("select * from dogs where name= '#{name}' and breed ='#{breed}'")

      if !dog.empty?
        dog_data = dog[0]
        new_dog = Dog.new(id:dog_data[0], name:dog_data[1], breed:dog_data[2] )
      else
        new_dog = self.create(name:name, breed:breed)
      end
      new_dog
    end

    def self.find_by_name(name)
      sql = "SELECT * from dogs where name=? limit 1"
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
    end

    def self.new_from_db(row)
      Dog.new(id:row[0], name:row[1], breed:row[2])
    end
end

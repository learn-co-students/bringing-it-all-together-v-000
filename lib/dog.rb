class Dog
  attr_accessor :name, :breed, :id
  @@all = []

  def initialize(id:nil,name:, breed:)
    @name = name
    @breed = breed
    @id = id
    @@all << self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
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

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL

    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes_hash)
    new_dog = self.new(attributes_hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
        SQL

    dog_data = DB[:conn].execute(sql,id)[0]
  #  binding.pry
    self.new(id:dog_data[0],name:dog_data[1],breed:dog_data[2])
  end

  def self.find_or_create_by(name:,breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = self.find_by_id(dog_data[0])
    else
      dog = self.create(name:name,breed:breed)
    end
    dog
  end

  def self.new_from_db(row)
    dog_new = self.new(id:row[0],name:row[1],breed:row[2])
    dog_new
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

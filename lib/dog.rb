class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
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
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(name:,breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
  end

  def self.new_from_db(row)
    dog = self.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_by_id(id)
    DB[:conn].execute("SELECT * FROM dogs WHERE id = ? LIMIT 1",id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).flatten
    if !dog.empty?
      dog = Dog.new(id:dog[0],name:dog[1],breed:dog[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1",name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?",self.name, self.breed, self.id)
  end
end

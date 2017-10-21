class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY, name TEXT, breed TEXT
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
    if self.id
      self.update
      self
    else
      sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
            SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
            SQL
    result = DB[:conn].execute(sql, id)[0]
    Dog.new_from_db(result)
  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_or_create_by(hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])[0]
    if dog != nil
      self.new_from_db(dog)
    else
      self.create(hash)
    end
  end

  def self.find_by_name(name)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new_from_db(dog)
  end

  def update
    sql = <<-SQL
          UPDATE dogs SET name = ?, breed = ? WHERE id = ?
          SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
end

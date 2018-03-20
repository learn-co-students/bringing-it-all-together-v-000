class Dog

attr_accessor :name, :breed, :id

  def initialize(name: nil, breed: nil, id: nil)
    @name = name
    @breed = breed
    @id = id
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
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs(name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(hash)
    dog = Dog.new
    dog.breed = hash[:breed]
    dog.name = hash[:name]
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    dog = Dog.new(name: result[1], id: result[0], breed: result[2])
    dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, album: breed)
    end
    dog
  end

  def self.new_from_db(row)
    new_song = self.new
    new_song.id = row[0]
    new_song.name =  row[1]
    new_song.breed = row[2]
    new_song
  end

  def self.find_by_name(name)
   sql = <<-SQL
     SELECT *
     FROM dogs
     WHERE name = ?
     LIMIT 1
   SQL

   DB[:conn].execute(sql, name).map do |row|
     self.new_from_db(row)
   end.first
 end




end

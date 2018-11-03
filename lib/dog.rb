class Dog

  attr_accessor :name, :breed, :id

  def initialize(name: , breed: , id: nil)
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
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attr_hash)
    # binding.pry
    dog = Dog.new(name: attr_hash[:name], breed: attr_hash[:breed], id: attr_hash[:id])
    dog.save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog_row = DB[:conn].execute(sql, id)
    new_dog = Dog.new(name: dog_row[0][1], breed:dog_row[0][2], id: dog_row[0][0])
  end

  def self.find_or_create_by(attr_hash)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, attr_hash[:id])
    binding.pry
    if result == nil
      self.create(attr_hash)
    else
      "fishsticks"
    end
    # if result == nil
    # Dog.new
    # end

  end

  def self.find_or_create_by(attr_hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND album = ?", name, album)
    if !song.empty?
      song_data = song[0]
      song = Song.new(song_data[0], song_data[1], song_data[2])
    else
      song = self.create(name: name, album: album)
    end
    song
  end


end

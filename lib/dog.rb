class Dog
  attr_accessor :name, :breed, :id
  # attr_reader

  def initialize(name:, breed:, id: nil)
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

  def save
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
        something = DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
  end

  def self.create(name:, breed:)
    d = self.new(name: name, breed: breed)
    d.save
    d
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    something = Dog.new(name: result[1], breed: result[2], id: result[0])
    something
  end

  def self.find_or_create_by(name:, breed:)
    song = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !song.empty?
      song_data = song[0]
      song = Dog.new(name: song_data[1], breed: song_data[2],  id: song_data[0])
    else
      song = self.create(name: name, breed: breed)
    end
    song
  end

  def self.new_from_db(row)
    dog = self.new(name: row[1], breed: row[2],id: row[0])
    dog
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

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

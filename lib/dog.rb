class Dog
  attr_accessor :id, :name, :breed
  @@all = []

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
    @@all << self
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
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

  def self.find_or_create_by(name:, album:)
     song = DB[:conn].execute("SELECT * FROM songs WHERE name = ? AND album = ?", name, album)
     if !song.empty?
       song_data = song[0]
       song = Song.new(song_data[0], song_data[1], song_data[2])
     else
       song = self.create(name: name, album: album)
     end
     song
   end

end

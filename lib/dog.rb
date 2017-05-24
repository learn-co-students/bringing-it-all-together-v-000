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
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        );
          SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  def save
    self.update if self.id
      else
        DB[:conn].execute("INSERT INTO dogs (name,breed) VALUES (?,?)", self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self #returns called object with newly added id
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])  #because this lab is awful and init uses symbols
  end

  def self.find_by_name(name)
    new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten)
  end

  def self.find_by_id(id)
    new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed).first
    !dog ? self.create(name: name, breed: breed) : self.new(id: dog[0], name: dog[1], breed: dog[2])
  end

  def update #upd db from curr obj
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end
end

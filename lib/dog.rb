
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  @@all = []

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self::create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self::drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def self::create(id: nil, name:, breed:)
    dog = self.new(id: id, name: name, breed: breed)
    dog.save
    @@all << dog
    dog
  end

  def self::find_by_id(dog_id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = (?)
    SQL

    new_from_db(DB[:conn].execute(sql, dog_id).flatten)
  end

  def self::new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self::find_by_name(dog_name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = (?)
    SQL

    new_from_db(DB[:conn].execute(sql, dog_name).flatten)
  end

  def self::find_or_create_by(attributes)
    array = []
    attributes.each {|key, value| array << value}
    dog_name = array[0]
    dog_breed = array[1]
    if @@all.any? {|dog| dog.name == dog_name && dog.breed == dog_breed}
      @@all.detect {|dog| dog.name == dog_name && dog.breed == dog_breed}
    else
      dog = create(name: dog_name, breed: dog_breed)
    end
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

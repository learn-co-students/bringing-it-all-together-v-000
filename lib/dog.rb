class Dog

  attr_accessor :id, :name, :breed
  @@all = []

  def initialize(hash)
    @id = hash[:id]
    @name = hash[:name]
    @breed = hash[:breed]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT,
        breed TEXT);
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?);
    SQL
    DB[:conn].execute(sql, self.name, self.breed)

    sql_2 = <<-SQL
      SELECT id FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    self.id = DB[:conn].execute(sql_2, self.name, self.breed)[0][0]
    @@all << self
    self
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    @@all.detect {|dog| dog.id == id}
  end

  def self.find_or_create_by(hash)
    if hash[:id]
      self.find_by_id(hash[:id])
      # @@all.detect{|dog| dog.name == hash[:name] && dog.breed == hash[:breed]}
    else
      self.create(hash)
    end
  end

  def self.new_from_db(array)
    hash = {:id => array[0], :name => array[1], :breed => array[2]}
    new_dog = self.new(hash)
  end

  def self.find_by_name(name)
    @@all.detect {|dog| dog.name == name}
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

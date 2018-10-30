require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  @@all = Array.new

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
    @@all << self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PIRIMARY KEY
        name TEXT
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
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = self.new({:name => name, :breed => breed})
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    our_dog = DB[:conn].execute(sql, id)[0]
    @@all.detect {|dog| dog.id == id}
  end

  def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed = ?', name, breed)
      if !dog.empty?
        id_name_breed = dog[0]
        dog = self.new({:id => id_name_breed[0], :name => id_name_breed[0], :breed => id_name_breed[1]})
      else
        dog = self.create(:name => name, :breed => breed)
      end
      dog
  end

  def self.new_from_db(row)
    dog = self.new({:id => row[0], :name => row[1], :breed => row[2]})
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL
    id_name_breed = DB[:conn].execute(sql, name)[0]
    our_dog = @@all.detect {|dog| dog.id == id_name_breed[0] && dog.name == id_name_breed[1] && dog.breed == id_name_breed[2]}
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

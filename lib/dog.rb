class Dog

  attr_accessor :id, :name, :breed

  @@all = []

  def initialize(hash={})
    hash = {id: nil, name: "", breed: ""}.merge(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
    @@all << self
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

  def self.new_from_db(row)
    dog = Dog.new
    dog.id = row[0]
    dog.name = row[1]
    dog.breed = row[2]
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.id == ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map do |row|
      @@all.detect{|dog| dog.id == row[0]}
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.name == ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def save
    dog = nil
    if Dog.find_by_id(self.id)
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    dog = Dog.find_by_id(self.id)
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def update
    if Dog.find_by_id(@id)
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  end

  def self.find_or_create_by(hash)
    dog = @@all.detect{|dog| dog.name == hash[:name]}
    if dog && dog.breed == hash[:breed]
      dog
    else
      self.create(hash)
    end
  end

# - References
# -- http://johnpwood.net/2011/04/11/optional-method-parameters-in-ruby/
# -- https://stackoverflow.com/questions/10234406/ruby-methods-and-optional-parameters

end

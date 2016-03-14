class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT
        grade INTEGER
      );
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql)
  end

  def save
      sql = "INSERT INTO dogs(name, breed) VALUES (?,?)"
      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").first.first
  end

  def self.create(h)
    Dog.new(h).tap(&:save)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?;"
    self.new_from_db(DB[:conn].execute(sql,id).first)
  end

  def self.find_or_create_by(dog_hash)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])
    if !dog.empty?
      self.find_by_id(dog[0][0])
    else
      self.create(dog_hash)
    end
  end

  def self.new_from_db(dog_array)
    Dog.new({id: dog_array[0], name: dog_array[1], breed: dog_array[2]})
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?;"
    self.new_from_db(DB[:conn].execute(sql,name).first)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

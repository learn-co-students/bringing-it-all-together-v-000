class Dog
attr_accessor :name, :id
attr_reader :breed

  def initialize(id = nil,name,breed)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-sql
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    sql
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-sql
      DROP TABLE dogs
    sql
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-sql
      INSERT INTO dogs (name,breed)
      VALUES (?,?)
    sql
    DB[:conn].execute(sql,self.name,self.breed)
    saved_dog_id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    self.id = saved_dog_id
  end

  def self.create(hash)
    name = hash[:name]
    breed = hash[:breed]
    new_dog = Dog.new(name,breed)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    Dog.new(row[0],row[1],row[2])
  end

  def self.find_by_id(id)
    sql = <<-sql
      SELECT * FROM dogs
      WHERE id = ?
      ORDER BY id ASC
      LIMIT 1
    sql
    row = DB[:conn].execute(sql,id)[0]
    Dog.new(row[0],row[1],row[2])
  end

  def self.find_or_create_by(name:,breed:)
    q = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}';")
    if q.length > 0
      Dog.new_from_db(q[0])
    else
      self.create(name:name,breed:breed)
    end
  end

  def self.find_by_name(name)
    sql = <<-sql
      SELECT * FROM dogs
      WHERE name = ?
      ORDER BY id ASC
      LIMIT 1
    sql
    row = DB[:conn].execute(sql,name)[0]
    Dog.new(row[0],row[1],row[2])
  end
end



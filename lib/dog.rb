class Dog
  attr_accessor :name,:breed
  attr_reader :id

  def initialize(id:nil,name:,breed:)
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
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = 'DROP TABLE dogs'
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    dog_hash = {id:row[0],name:row[1],breed:row[2]}
    self.new(dog_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = (?)
      LIMIT 1
    SQL
    dog_row = DB[:conn].execute(sql,name)[0]
    if dog_row != nil
      self.new_from_db(dog_row)
    end
  end

  def self.find_by_breed(breed)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE breed = (?)
      LIMIT 1
    SQL
    dog_row = DB[:conn].execute(sql,breed)[0]
    if dog_row != nil
      self.new_from_db(dog_row)
    end
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = (?)
      LIMIT 1
    SQL
    dog_row = DB[:conn].execute(sql,id)[0]
    if dog_row != nil
      self.new_from_db(dog_row)
    end
  end

  def self.find_or_create_by(dog_hash)
    if self.find_by_name(dog_hash[:name]) == nil || self.find_by_breed(dog_hash[:breed]) == nil
      self.create(dog_hash)
    else
      self.find_by_name(dog_hash[:name])
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
      DB[:conn].execute(sql,self.name,self.breed)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = (?), breed = (?)
      WHERE id = (?)
    SQL
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end

  def self.create(dog_hash)
    self.new(dog_hash).save
  end

end

class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
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

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      return self
    end
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end


  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    self.all.each do |student|
      if student.id == id
       return student
      end
    end
  end

  def self.find_or_create_by(dog_hash)
    dog_name = dog_hash[:name]
    dog_breed = dog_hash[:breed]

    if found_dog = self.find_by_name(dog_name)
       if self.find_by_name(dog_name).breed == dog_breed
         self.find_by_name(dog_name)
       else
         new_dog = self.create(dog_hash)
         new_dog.save
         new_dog
       end
    else
      new_dog = self.create(dog_hash)
      new_dog.save
      new_dog
    end

  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    dog_hash = {:name => name, :breed => breed, :id => id}
    new_dog = self.new(dog_hash)
    new_dog
  end

  def self.find_by_name(name)
    self.all.each do |dog|
     if dog.name == name
      return dog
     end
   end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize (id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
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
      DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql) 
  end

  def save
    #First, check to see if instance has an self.id
      #i.e., if it has been persisted in the db
    if self.id
      #if self.id exists, then #update
      #otherwise, you would create two records in the db
      self.update
    #Second, if no self.id, therefore not persisted in db
    else
      #insert into db with instance name and breed
      sql = <<-SQL 
        INSERT INTO dogs (name, breed)
        VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      #get PRIMARY KEY from db, remember it returns an array of array
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id) 
  end

  def self.create(name:, breed:)
    #Note: keyword arguments do not take an input in #initialize
    #they do take input when called
    self.new(name: name, breed: breed).tap do |dog|
      dog.save
    end
  end

  def self.find_by_id(id)
    #First, find the db record matching id
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?;
    SQL
    #remember the return is an array of array
    dog = DB[:conn].execute(sql, id)[0]
    #Second, new Dog instance, keep in mind keyword args
    self.new(id: dog[0], name: dog[1], breed: dog[2]) 
  end

  def self.find_or_create_by(name:, breed:)
    #First, see if db has record with matching name and breed
    dog_record = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
    #Second, if record exists, create corresponding ruby object
    if !dog_record.empty?
      dog_data = dog_record[0]
      dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    #Third, if not exist, create db record and ruby object
    else
      dog = self.create(name: name, breed: breed)
    end
    #Fourth, should return dog instance
    dog
  end

  def self.new_from_db(row)
    dog = self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    #Goal is to locate record based on string name, create dog instance from record data
    #First, locate record in db, based on string name
    sql = <<-SQL 
    SELECT * FROM dogs WHERE name = ?;
    SQL
    row = DB[:conn].execute(sql, name)[0]
    #Second, create instance using #new_from_db
    self.new_from_db(row)
  end





end
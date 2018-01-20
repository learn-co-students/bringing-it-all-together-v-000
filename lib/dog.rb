require'pry'

  class Dog

  attr_accessor :name, :breed, :id
  # attr_reader :id

  def initialize(attributes, id = nil)
    @id = id
    attributes.each {|key, value| self.send(("#{key}="), value)}
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT)
    SQL
    DB[:conn].execute(sql);
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs");
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
    @id = DB[:conn].execute("SELECT
    last_insert_rowid() FROM dogs")[0][0]
    self
    end
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name= ?, breed= ?
    WHERE id= ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(attributes) # instantiates new dog and saves it to the DB
    new_dog = self.new(attributes)
    new_dog.save
    new_dog
  end

  def self.new_from_db(array)
    attributes = {id:array[0], name:array[1], breed:array[2]}
    new_dog = self.new(attributes)
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    new_dog = self.new(id: row[0], name:row[1], breed:row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name= ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    new_dog = self.new(id: row[0], name:row[1], breed:row[2])
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name= ? AND breed= ?
    SQL
      if DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]# this is evaluating to true, but it is returning an empty array for the sql select statement?
        array = DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0] #capture array returned from SQL select statement above
        self.new_from_db(array)
       else
         self.create(attributes) # else create and save to DB
      end
    end

  end # end of class

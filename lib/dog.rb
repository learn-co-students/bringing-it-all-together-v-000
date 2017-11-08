require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @name = name;
    @breed = breed;
    @id = id;
  end

  #instance methods
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, @name, @id);
    sql = <<-SQL
      UPDATE dogs SET breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, @breed, @id);
  end

  def save
    test = Dog.find_by_id(@name) == nil
    if test
      sql = <<-SQL
        INSERT INTO dogs(name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, @name, @breed);
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
     update();
    end
    self
  end
  #class method
  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed);
    new_dog.save;
  end

  def self.create_table
=begin  sql = <<-SQL
      DROP TABLE dogs;
    SQL

    #DB[:conn].execute(sql);
=end
  DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    sql = <<-SQL
      CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
    SQL
      DB[:conn].execute(sql);
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql);
  end

  def self.new_from_db(data)
    new_dog = Dog.new(name: data[1], breed: data[2], id: data[0]);
    if data.length == 0
       nil
    else
      new_dog
    end
  end

  def self.find_by_name(name)
    sql=  <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    data = DB[:conn].execute(sql, name);

    if data.length == 0
      nil
    else
      Dog.new_from_db(data[0]);
    end

  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    data = DB[:conn].execute(sql, id);
    if data.length == 0
      nil
    else
        Dog.new_from_db(data[0]);
    end
  end

  def self.find_or_create_by(name:, breed:)
    sql=  <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    data = DB[:conn].execute(sql, name, breed);

    if data.length == 0
         Dog.create(name: name, breed: breed)
    else
        Dog.new_from_db(data[0]);
    end

  end

end

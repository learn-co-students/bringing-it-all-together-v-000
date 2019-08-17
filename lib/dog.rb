require_relative "../config/environment.rb"

class Dog
  attr_accessor :id, :name, :breed

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def save
    if self.id
      self.update
    else
      save_sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(save_sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self
  end

  def update
    update_sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
    DB[:conn].execute(update_sql, self.name, self.breed, self.id)
  end

  def self.create_table
    create_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(create_sql)
  end

  def self.drop_table
    drop_sql = <<-SQL
    DROP TABLE dogs;
    SQL
    DB[:conn].execute(drop_sql)
  end

  def self.new_from_db(array)
    dog = self.new(id:array[0], name:array[1], breed:array[2])
  end

  def self.find_by_id(id)
    find_id_sql = "SELECT * FROM dogs WHERE id = ?;"
    found = DB[:conn].execute(find_id_sql, id)[0]
    Dog.new(id:found[0], name:found[1], breed:found[2])
  end

  def self.find_by_name(name)
    find_name_sql = "SELECT * FROM dogs WHERE name = ?;"
    found = DB[:conn].execute(find_name_sql, name)[0]
    Dog.new(id:found[0], name:found[1], breed:found[2])
  end

  def self.create(name:, breed:)
    dog = Dog.new(name:name, breed:breed)
    dog.save
    dog
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new(id:dog_info[0], name:dog_info[1], breed:dog_info[2])
    else
      dog = self.create(name:name, breed:breed)
    end
    dog
  end

end

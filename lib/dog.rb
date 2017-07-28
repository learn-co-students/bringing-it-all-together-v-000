class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil,name: name, breed: breed)
    self.name = name
    self.breed = breed
    self.id = id
  end

  ### create a new dog and save it to database ###

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).tap{|dog| dog.save}
  end

  ### creates new instance from the database ###

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  ### save a dog record ###

  def save
    save_sql = <<-SQL
      INSERT INTO dogs(name, breed) VALUES (?, ?);
    SQL

    self.class.db_exec(save_sql, self.name, self.breed)

    load_sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL

    loaded_data = self.class.db_exec(load_sql, self.name, self.breed)[0]

    self.id = loaded_data[0]
    self
  end


  ### create table ###

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    self.db_exec(sql)
  end

  ### drop the table ###

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL

    self.db_exec(sql, nil)
  end


  ### custom db execution ###

  def self.db_exec(sql, *args)
    if args[0]
      DB[:conn].execute(sql, *args)
    else
      DB[:conn].execute(sql)
    end
  end

  ### finds record by id ###

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL

    data = self.db_exec(sql, id)[0]
    if data
      self.new_from_db(data)
    end
  end

  def self.find_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = (?) AND breed = (?);
    SQL
    data = self.db_exec(sql, name, breed)[0]
    if data
      self.new_from_db(data)
    end
  end

  def self.find_or_create_by(name:, breed:)
    self.find_by(name: name, breed: breed) ? self.find_by(name: name, breed: breed) : self.create(name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL

    self.new_from_db(self.db_exec(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL

    self.class.db_exec(sql, self.name, self.breed, self.id)
  end

end

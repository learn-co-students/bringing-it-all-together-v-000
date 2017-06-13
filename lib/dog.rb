class Dog
  attr_accessor :id, :name, :breed
  def initialize(name: , breed: , id: nil)
    @id = id
    @name = name
    @breed = breed
  end
  def self.create_table
    sql_query = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
                  SQL
    DB[:conn].execute(sql_query)
  end
  def self.drop_table
    sql_query = <<-SQL
      DROP TABLE IF EXISTS dogs
                   SQL
    DB[:conn].execute(sql_query)
  end
  def update
    sql_query = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
                SQL
    DB[:conn].execute(sql_query, @name, @breed, @id)
  end
  def save
    if(@id == nil)
      sql_query = <<-SQL
        INSERT INTO dogs(name, breed) VALUES(?,?)
                    SQL
      DB[:conn].execute(sql_query, @name, @breed)
      sql_query = <<-SQL
        SELECT last_insert_rowid() FROM dogs
                  SQL
      @id = DB[:conn].execute(sql_query).flatten.first
    else
      update
    end
    return self
  end
  def self.create(name: , breed: )
    d = Dog.new(name: name, breed: breed)
    d.send("#{:name}=", name)
    d.send("#{:breed}=",breed)
    d.save
  end
  def self.find_by_id(id)
    sql_query = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
                SQL
    row = DB[:conn].execute(sql_query, id).flatten
    Dog.new(name: row[1],breed: row[2],id: row[0])
  end
  def self.find_or_create_by(name: , breed: )
    sql_query = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
                SQL
    row = DB[:conn].execute(sql_query, name, breed).flatten
    if(row.empty?)
      return create(name: name, breed: breed)
    else
      return Dog.new(name: row[1], breed: row[2], id: row[0])
    end
  end
  def self.new_from_db(row)
    Dog.new(name: row[1],breed: row[2],id: row[0])
  end
  def self.find_by_name(name)
    sql_query = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1;
              SQL

    row = DB[:conn].execute(sql_query,name).flatten

    if(row.empty?)
      return nil
    end
    return Dog.new(name: row[1], breed: row[2], id: row[0])
  end
end

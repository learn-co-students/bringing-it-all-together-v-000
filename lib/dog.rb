class Dog
  attr_accessor :id, :name, :breed
  def initialize(id:nil, name:, breed:)
    @id= id
    @name=name
    @breed=breed
  end

  def self.create_table
    sql=<<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql=<<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
      new_dog=self.new(id:row[0],name:row[1],breed:row[2])
      new_dog
  end

  def save
    if self.id
      self.update
    else
    sql=<<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?,?)
    SQL


    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    return self
  end

  def update
    sql=<<-SQL
    UPDATE dogs SET name =?, breed =? WHERE id=?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


  def self.find_by_name(name)
    sql=<<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL

    row=DB[:conn].execute(sql, name).flatten
    self.new_from_db(row)
  end

  def self.create(name:, breed:)
    new_dog=self.new(name:name,breed:breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql=<<-SQL
    SELECT * FROM dogs
    WHERE id=?
    SQL

    row=DB[:conn].execute(sql,id).flatten
    self.new_from_db(row)

  end

  def self.find_or_create_by(name:,breed:)
    dog=DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?",name,breed)
    if !dog.empty?
      self.new(id:dog[0][0],name:dog[0][1],breed:dog[0][2])
    else
      self.create(name:name, breed:breed)
    end
  end



end

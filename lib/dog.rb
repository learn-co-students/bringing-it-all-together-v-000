class Dog 

  attr_accessor :name, :breed, :id

  def initialize (id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = "create table if not exists dogs (id integer primary key, name text, breed text)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "drop table dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = "insert into dogs (name, breed) values (?, ?)"
    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
  end

  def self.create(name: ,breed: )
    dog = self.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "select * from dogs where id = ?"
    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end

  def self.find_or_create_by(name: ,breed:)
    song = DB[:conn].execute("select * from dogs where name = ? and breed = ?", name, breed)
    if song.empty?  
      self.create(name: name, breed: breed)
    else
      self.new_from_db(song[0])
    end 
  end

  def self.new_from_db(row)
    self.new(id: row[0],name: row[1],breed: row[2])
  end

  def self.find_by_name(name)
    sql = "select * from dogs where name = ?"
    row = DB[:conn].execute(sql, name)[0]
    self.new(id: row[0],name: row[1],breed: row[2])
  end

  def update
    sql = "update dogs set name = ?, breed = ? where id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end 
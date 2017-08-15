class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      create table if not EXISTS dogs (
        id integer primary key,
          name text,
          breed text
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      drop table dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        insert into dogs (name, breed)
        values (?, ?);
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute('select last_insert_rowid() from dogs')[0][0]
      self
    end
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      select *
      from dogs
      where id = ?
    SQL

    something = DB[:conn].execute(sql, id).flatten
    self.new(id: something[0], name: something[1], breed: something[2])
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      select *
      from dogs
      where name = ?
    SQL

    row = DB[:conn].execute(sql, name).flatten
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name:, breed:)
    dog_breed = DB[:conn].execute('select * from dogs where name = ? and breed = ?', name, breed)
    if !dog_breed.empty?
      dog_info = dog_breed[0]
      new_dog = self.new(id: dog_info[0],name: dog_info[1], breed: dog_info[2])
    else
      new_dog = self.create(name: name, breed: breed)
    end
      new_dog
  end

  def update
    sql = <<-SQL
      update dogs set name = ?, breed = ?
      where id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

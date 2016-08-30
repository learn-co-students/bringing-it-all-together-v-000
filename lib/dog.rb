class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-sql
      create table if not exists dogs(
      id integer primary key,
      name text,
      breed text
      )
    sql

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-sql
      drop table if exists dogs
    sql

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    sql = <<-sql
      select * from dogs
      where name = ?
      limit 1
    sql

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-sql
      update dogs
      set name = ?,
      breed = ?
      where id = ?
    sql

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-sql
        insert into dogs(name, breed)
        values(?, ?)
      sql

      DB[:conn].execute(sql, self.name, self.breed)

      sql2 = <<-sql
        select last_insert_rowid()
        from dogs
      sql

      @id = DB[:conn].execute(sql2)[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-sql
      select *
      from dogs
      where id = ?
      limit 1
    sql

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("select * from dogs where name = '#{name}' and breed = '#{breed}'")
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
end

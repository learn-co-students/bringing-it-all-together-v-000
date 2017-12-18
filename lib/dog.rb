class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      create table if not exists dogs (
        id integer primary key,
        name text,
        breed text
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "drop table if exists dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = "insert into dogs (name, breed) values (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('select last_insert_rowid() from dogs')[0][0]
    self
  end

  def self.create(id: nil, name:, breed:)
    dog = Dog.new(id: nil, name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      select *
      from dogs
      where id = ?
    SQL
    dog_info = DB[:conn].execute(sql, id)[0]
    dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    dog
  end

  def self.find_or_create_by(name:,breed:)
    dog = DB[:conn].execute("select * from dogs where name = ? and breed = ?", name, breed)
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
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
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
  sql = <<-SQL
    update dogs
    set name = ?, breed = ?
    where id = ?
  SQL
  DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end

class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id:nil, name:nil, breed:nil)
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
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("drop table dogs")
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      select * from dogs
      where name = ?
    SQL

    DB[:conn].execute(sql, name).flatten
  end

  def self.create(attributes)
    dog = self.new(name: attributes[:name], breed: attributes[:breed])
    dog.save
    dog
  end

  def update
    sql = <<-SQL
      update dogs
      set name = ?, breed = ?
      where id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def save
    if @id.nil?
      sql = <<-SQL
        insert into dogs (name, breed)
        values (?, ?)
      SQL

      DB[:conn].execute(sql, @name, @breed)
      @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
    else
      update
    end

    self
  end

  def self.find_by_id(id)
    sql = <<-SQL
      select * from dogs
      where id = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, id).flatten)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      select * from dogs
      where name = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      select * from dogs
      where name = ? and breed = ?
    SQL

    result = DB[:conn].execute(sql, name, breed)

    if !result.empty?
      self.find_by_id(result[0][0])
    else
      self.create(name: name, breed: breed)
    end
  end

end

class Dog
attr_accessor :id, :name, :breed

  def initialize (hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
  end

  def self.create_table
    sql = <<-pie
      create table if not exists dogs (
        id integer primary key,
        name text,
        breed text)
      pie
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('drop table if exists dogs')
  end

  def self.new_from_db(row)
    hash = {}
    hash[:id] = row[0]
    hash[:name] = row[1]
    hash[:breed] = row[2]
    self.new(hash)
  end

  def self.find_by_name(name)
    sql = "select * from dogs where name = ?"
    self.new_from_db(DB[:conn].execute(sql,name).first)
  end

  def update
    sql = "update dogs set name = ?, breed = ? where id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        insert into dogs(name, breed)
        values (?, ?)
        SQL
      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute('select last_insert_rowid() from dogs')[0][0]
    end
    self
  end

  def self.create(hash)
    x = self.new(hash)
    x.save
  end

  def self.find_by_id(id)
    sql = "select * from dogs where id = ?"
    self.new_from_db(DB[:conn].execute(sql,id).first)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute('select * from dogs where name = ? and breed = ?', name, breed)
    if !dog.empty?
      d = dog[0]
      dog_obj = Dog.new_from_db(d)
    else
      hash = {
              name: name,
              breed: breed}
      Dog.create(hash)
    end
  end

end

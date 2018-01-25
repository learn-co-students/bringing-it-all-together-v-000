require_relative "../config/environment.rb"

class Dog
  
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    @name=name
    @id=id
    @breed=breed
  end
  
  def self.create_table
    sql=<<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql=<<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
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
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end

  end

  def self.create(attributes)
    dog=self.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
     sql = <<-SQL
      SELECT *
      FROM dogs 
      WHERE id = ? 
      LIMIT 1
    SQL

     DB[:conn].execute(sql,id).map do |row|
       self.new_from_db(row)
    end.first

  end

  def self.new_from_db(row)
    attributes ={name: row[1], id: row[0], breed: row[2]}
    self.new(attributes)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
       dog = self.new_from_db(dog[0])
    else
      
      dog = self.create(name: name, breed: breed)
    end
    dog

  end

  def self.find_by_name(name)
    sql=<<-SQL
      SELECT * FROM dogs WHERE name=?
      SQL
       DB[:conn].execute(sql,name).map do |row|
        self.new_from_db(row)
    end.first
  end

  def update()
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end#end class
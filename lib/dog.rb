require 'pry'

class Dog

attr_accessor :name, :breed
attr_reader :id

  def initialize(attr_hash)
    # if attr_hash.is_a?(Hash)
    #   binding.pry
    #   @id = attr_hash{"#{id}"}
    #   @name = attr_hash{"#{name}"}
    #   @breed = attr_hash{"#{breed}"}
    # else
      @id = attr_hash[:id]
      @name = attr_hash[:name]
      @breed = attr_hash[:breed]
    # end
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql =  <<-SQL
      DROP TABLE dogs
        SQL
    DB[:conn].execute(sql)
  end

  def save
      if self.id
        self.update
      else
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
     end
     self
  end

  def self.create(attr_hash)
     dog = self.new(attr_hash)
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
      attr_hash = {:id=>row[0], :name=>row[1], :breed=>row[2]}
      self.new(attr_hash)
    end.first
  end

  def self.find_or_create_by(some_hash)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", some_hash[:name], some_hash[:breed])
    dog_data = dog[0]
    # binding.pry
    if !dog.empty?
      attr_hash = {:id=>dog_data[0], :name=>dog_data[1], :breed=>dog_data[2]}
      dog = Dog.new(attr_hash)
    else
      dog = self.create(some_hash)
    end
    dog
  end

  def self.new_from_db(row)
    self.new({:id=>row[0], :name=>row[1], :breed=>row[2]})
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

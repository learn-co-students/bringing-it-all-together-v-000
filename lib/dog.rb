class Dog

  attr_accessor :name, :breed, :id


def initialize(id: nil, name:, breed:)
  @id = id
   @name = name
    @breed = breed
  end


def self.create_table
  sql = <<-SQL
   Create Table IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
   SQL
    DB[:conn].execute(sql)
  end

def self.drop_table
  sql = "DROP TABLE IF EXISTS dogs"
   DB[:conn].execute(sql)
  end

def save
 if self.id
    self.update
else
 sql = <<-SQL
INSERT INTO dogs (name, breed) VALUES (?, ?)
 SQL
DB[:conn].execute(sql, self.name, self.breed)
 @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end
 self
end

def self.create(name:, breed:)
  dog = self.new(name: name, breed: breed)
  dog.save
  dog
 end


def self.find_by_id(id)
 sql = <<-SQL
  SELECT * FROM dogs WHERE id = ?
   LIMIT 1
  SQL

  DB[:conn].execute(sql,id).map do |row|
   self.new_from_db(row)
  end.first
end

def self.new_from_db(new_dogs)
 id = new_dogs[0]
 name = new_dogs[1]
 breed = new_dogs[2]
 self.new(id: id, name: name, breed: breed)
 end

  

end

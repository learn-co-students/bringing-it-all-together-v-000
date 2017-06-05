class Dog
#-------------------------------------------------------------------------------------------
#macros & meta
attr_accessor :name, :breed
attr_reader :id


def initialize (arguments)
    @name = arguments[:name]
    @breed = arguments[:breed]
    @id = arguments[:id]
end



#-------------------------------------------------------------------------------------------
#instance

#-----
def save
    if self.id
    self.update
    else
    self.insert
    end
    self
end
#-----

def update
    sql = <<-SQL
          UPDATE dogs
          set name = ?, breed = ?
          WHERE id = ?
          SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
end

#-----
def insert
    sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?,?)
          SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs;")[0][0]
end



#-------------------------------------------------------------------------------------------
#class
#-----
def self.new_from_db(row)
    #binding.pry
Dog.new(name: row[1],breed: row[2], id: row[0])
end

#-----
def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT    
          );
          SQL
    DB[:conn].execute(sql)
end


#-----
def self.drop_table
    sql = <<-SQL
          DROP TABLE IF EXISTS dogs;
          SQL
    DB[:conn].execute(sql)
end

#-----
def self.create(arguments)
    Dog.new(arguments).save 
end

def self.find_by_id(id)
    
    sql = <<-SQL
          SELECT * from dogs where id = ?
          SQL

    if DB[:conn].execute(sql, id)[0]
          Dog.new_from_db(DB[:conn].execute(sql, id)[0])
    end
end

def self.find_by_name(name)
    
    sql = <<-SQL
          SELECT * from dogs where name = ?
          SQL

    if !DB[:conn].execute(sql, name).empty?
          Dog.new_from_db(DB[:conn].execute(sql, name)[0])
    end
end

def self.find_by_name_and_breed(arguments)
    
    sql = <<-SQL
          SELECT * from dogs where name = ? AND breed = ?
          SQL
      #binding.pry 
    if !DB[:conn].execute(sql, arguments[:name], arguments[:breed]).empty?
        #binding.pry
        Dog.new_from_db(DB[:conn].execute(sql, arguments[:name], arguments[:breed])[0])
    else
        nil    
    end
end

def self.find_or_create_by(arguments)
    if Dog.find_by_name_and_breed(arguments)
    Dog.find_by_name_and_breed(arguments)
else
    #binding.pry
    Dog.create(arguments)
    end
end




#eoc
end

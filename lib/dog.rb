class Dog
#-------------------------------------------------------------------------------------------
#macros & meta
attr_accessor :name, :breed
attr_reader :id


def initialize (name: nil, breed: nil, id: nil)
    @name = name
    @breed = breed
    @id = id
end











#-------------------------------------------------------------------------------------------
#instance









#-------------------------------------------------------------------------------------------
#class
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

def self.drop_table
    sql = <<-SQL
          DROP TABLE IF EXISTS dogs;
          SQL
    DB[:conn].execute(sql)
end



#eoc
end

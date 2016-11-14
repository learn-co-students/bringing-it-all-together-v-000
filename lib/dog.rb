require "pry"
class Dog
attr_accessor :name, :breed
attr_reader :id
def initialize(doghash)
@name=doghash[:name]
@breed=doghash[:breed]
@id=doghash[:id]
end

def self.create_table
sql="create table  if not exists dogs (id number primary key, name text,breed text)"
DB[:conn].execute(sql)
end

def self.drop_table
sql="drop table if exists dogs"
DB[:conn].execute(sql)
end

def save
sql= "insert into dogs (name, breed) values(?,?)"
DB[:conn].execute(sql,self.name,self.breed)
sql= "select last_insert_rowid() from dogs"
@id=DB[:conn].execute(sql)[0][0]
self

end

def self.create(hashdog)
dog=Dog.new(hashdog)
dog.save
end

def self.new_from_db(row)
  Dog.new({:id=>row[0] , :name=>row[1] ,:breed=>row[2]})
end

def self.find_by_id(id)
  sql ="select * from dogs where id=?"
  row=DB[:conn].execute(sql,id)
  dog=new_from_db(row[0])
end

def self.find_or_create_by(doghash)
sql="select * from dogs where name=? and breed=?"
row=DB[:conn].execute(sql,doghash[:name],doghash[:breed])
if !row.empty?
   new_from_db(row[0])
else
   create(doghash)
 end
end

def self.find_by_name(name)
sql = "select * from dogs where name = ?"
row=DB[:conn].execute(sql,name)
if !row.empty?
new_from_db(row[0])
end
end

def update
sql="update dogs set name=? ,breed=? where id =?"
DB[:conn].execute(sql,self.name,self.breed,self.id)
end
 end

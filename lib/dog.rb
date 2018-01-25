class Dog

  attr_accessor :name, :breed
  attr_reader :id
 
   def initialize(id: nil, name:, breed:)
     @id = id
     @name = name
     @breed = breed
   end

  

  def self.create_table
    sql= <<-sql
          Create table if not exists dogs(
            id integer primary key,
            name text,
            breed text)
            sql
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql="drop table if exists dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-sql
        insert into dogs(name,breed)
        values(?,?)
        sql
    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("select last_insert_rowid() from dogs")[0][0]
  end


  def self.new_from_db(row)
    Dog.new(id:row[0],name:row[1],breed:row[2])
  end


  def self.create(name:,breed:)
    dog =Dog.new(name:name,breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql="select * from dogs where id= ? limit 1"
    row= DB[:conn].execute(sql,id)[0]
      Dog.new(id:row[0],name:row[1],breed:row[2])
    end

    def self.find_or_create_by(name:,breed:)
      sql="select * from dogs where name=? and breed =?"
      dog_data=DB[:conn].execute(sql,name,breed)[0]
      if !dog_data.nil?
         dog= Dog.new(id:dog_data[0],name:dog_data[1],breed:dog_data[2])
       else
        dog=Dog.create(name:name,breed:breed)
      end
      dog
    end


   def self.find_by_name(name)
    sql ="select * from dogs where name=?"
    dog=DB[:conn].execute(sql,name)[0]
    Dog.new_from_db(dog)
  end



end

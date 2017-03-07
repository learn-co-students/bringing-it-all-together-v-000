require 'pry'

class Dog

    attr_accessor :name, :breed, :id

    def initialize(inits)
        inits.each { |k,v| 
            self.send("#{k}=", v)
            }
    end

    def self.create_table
        sql = <<-SQL
CREATE TABLE IF NOT EXISTS dogs (
id INTEGER PRIMARY KEY,
name TEXT,
breed TEXT);
SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
DROP TABLE dogs
SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id 
            update
        else
            sql = <<-SQL
INSERT INTO dogs (name, breed) VALUES (?,?)
SQL
            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(inits)
        dog = Dog.new(inits)
        dog.save
        dog
    end
    
    def self.find_by_id(id)
        sql = <<-SQL
SELECT * FROM dogs WHERE id = ?
SQL
        row = DB[:conn].execute(sql, id)[0]
        if row
            dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        else
            dog = nil
        end
        return dog
    end
    
    def self.find_by_name(name)
        id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ?",name)
        find_by_id(id) 
    end
    def self.find_by_name_and_breed(name, breed)
        id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ? AND breed = ?",[name, breed])
        find_by_id(id)
    end
    
    def self.find_or_create_by(info)
        dog = find_by_name_and_breed(info[:name], info[:breed])
        
        if !dog
            dog = create(info)
        end
        dog
    end
    
    def self.new_from_db(row)
        create({name: row[1],breed: row[2],id: row[0]})
    end
    
    def update
        sql = <<-SQL
UPDATE dogs SET name = ?, breed = ? WHERE id = ?
SQL
        DB[:conn].execute(sql,self.name, self.breed, self.id)
        
    end
end
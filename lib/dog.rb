require 'pry'

class Dog
    attr_accessor :name, :breed
    attr_reader :id

  COLUMNS_NAME = {id: "INTEGER PRIMARY KEY", name: "TEXT", breed: "TEXT"}

  def self.columns_name_for_table
    COLUMNS_NAME.collect{|k,v|"#{k} #{v}"}.join(",")
  end

  def self.table_name
    "#{self}s"
  end
#-------------------------------------------------------------#
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{Dog.table_name}
      (#{self.columns_name_for_table} )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS #{Dog.table_name}")
  end

  def self.create(id:nil, name:, breed:)
    obj = self.new(id:id,name:name,breed:breed)
    obj.save
  end

  def self.find_by_id(id)
      sql = "SELECT * FROM #{Dog.table_name} WHERE id=?"
      obj_array = DB[:conn].execute(sql, id).flatten
    if obj_array.empty?
      puts "The Dog you are looking for was not found"
      else
      self.create( {id:obj_array[0], name:obj_array[1], breed:obj_array[2] } )
    end
  end

  def self.find_by_name (name)
    sql = "SELECT * FROM #{Dog.table_name} WHERE name=?"
    obj_array = DB[:conn].execute(sql, name).flatten
      if obj_array.empty?
        puts "The Dog you are looking for was not found"
        else
        self.create( {id:obj_array[0], name:obj_array[1], breed:obj_array[2] } )
      end
  end

  def self.find_or_create_by (id:nil,name:,breed:)
    self.create(id:id, name:name, breed:breed)
  end

  def self.new_from_db(obj_array)
    self.new(
    id:obj_array[0],name:obj_array[1],breed:obj_array[2] )
  end

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def save
      sql = <<-SQL
        SELECT * FROM #{Dog.table_name} WHERE name =? AND breed =?
          SQL
      table_array = DB[:conn].execute(sql, self.name, self.breed).flatten

      if table_array.empty?
        sql = <<-SQL
          INSERT INTO #{Dog.table_name}(name, breed)VALUES(?,?)
           SQL

           DB[:conn].execute(sql, self.name, self.breed)

          @id = DB[:conn].execute("select last_insert_rowid() FROM #{Dog.table_name}")[0][0]

          self
      else
          @id = DB[:conn].execute("select * from Dogs")[0][0]
          self
    end
  end

  def update
      sql = "UPDATE #{Dog.table_name} SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end

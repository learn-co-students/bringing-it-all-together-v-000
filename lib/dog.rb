class Dog
  attr_accessor :name, :breed
  attr_reader :id

    def initialize(id:nil, name:nil, breed:nil)
      @id = id
      @name = name
      @breed = breed
    end

    def self.create_table
      sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
              id INTEGER PRIMARY KEY,
              name TEXT,
              breed TEXT)
              SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      sql = <<-SQL
            DROP TABLE dogs
            SQL
      DB[:conn].execute(sql)
    end

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
      if self.id
        self.update
      else
        sql = <<-SQL
              INSERT INTO dogs (name, breed)
              VALUES (?, ?)
              SQL

        mdog = DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
      end
    end

    def self.create(hash)
      doggo = self.new(hash)
      doggo.save
      doggo
    end

    def self.new_from_db(arr)
      params = {id: arr[0], name: arr[1], breed: arr[2]}
      self.new(params)
    end

    def self.find_by_id(id)
      sql = "SELECT * FROM dogs WHERE id = ?"
      result = DB[:conn].execute(sql, id)[0]
      params = {id: result[0], name: result[1], breed: result[2]}
      self.new(params)
    end

    def self.find_by_name(name)
      pooch = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? ", name)
      self.new_from_db(pooch[0])
    end

    def self.find_or_create_by(name:, breed:)
        pooch = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !pooch.empty?
          self.new_from_db(pooch[0])
        else
          poodle = self.create(name:name, breed:breed)
        end
    end

end

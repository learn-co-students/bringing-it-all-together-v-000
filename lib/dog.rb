class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:,breed:, id: nil )
      @name = name
      @breed = breed
      @id = id
    end

    def self.create_table
      DB[:conn].execute('DROP TABLE IF EXISTS dogs')

      sql = <<-SQL
        CREATE TABLE dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL

      DB[:conn].execute(sql)
    end

    def save
      if !self.id
        sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (? , ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs ")[0][0]
      end
      self
    end

    def self.drop_table
        DB[:conn].execute('DROP TABLE IF EXISTS dogs')
    end

    def self.create(attributes)
      dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
      dog.save
    end

    def self.find_by_id(id)
      sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL

      row = DB[:conn].execute(sql, id).flatten
      dog = Dog.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_or_create_by(attributes)
      dog = DB[:conn].execute('SELECT * FROM dogs WHERE name = ? AND breed= ?', attributes[:name], attributes[:breed]).flatten
        if !dog.empty?
          find_by_id(dog[0])
        else
          create(attributes)
        end
      end

      def self.new_from_db(row)
          dog = self.new(name:row[1], breed:row[2], id:row[0])
      end

      def self.find_by_name(name)
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ?
        SQL

        row =  DB[:conn].execute(sql, name).flatten
        new_from_db(row)
      end
end

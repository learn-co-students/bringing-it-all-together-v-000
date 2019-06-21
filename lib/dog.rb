require 'pry'
require_relative '../config/environment.rb'
require 'sqlite3'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}


class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        new = self.new(name: hash[:name], breed: hash[:breed])
        new.save
        new
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).collect do |row|
            self.new(name: row[1], breed: row[2], id: row[0])
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
        SQL

        dog_data = DB[:conn].execute(sql, name, breed)
        if !dog_data.empty?
            attributes = dog_data[0]
            dog = self.new(name: attributes[1], breed: attributes[2], id: attributes[0])
        else dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.new_from_db(row)
        new = self.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL

        DB[:conn].execute(sql, name).collect do |row|
            self.new(name: row[1], breed: row[2], id: row[0])
        end.first
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end

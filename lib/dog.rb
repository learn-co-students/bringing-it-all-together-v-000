require 'pry'
class Dog

	attr_accessor :name, :breed, :id

	def initialize(hash)
		hash.each {|key, value| self.send(("#{key}="), value)}
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
		sql = "DROP TABLE IF EXISTS dogs;"
		DB[:conn].execute(sql)
	end

	def save
		sql = <<-SQL
			INSERT INTO dogs (name, breed)
			VALUES (?, ?)
		SQL

		DB[:conn].execute(sql, self.name, self.breed)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
	end

	def self.create(hash)
		new_dog = self.new(hash)
		new_dog.save
		new_dog
	end

	def self.find_by_id(id)
		sql = "SELECT * FROM dogs WHERE id = id"
		hash = %w{}
		DB[:conn].execute(sql).each do |x| 
			hash = {
				:id => x[0], 
				:name => x[1], 
				:breed => x[2]
			}
		end
		self.new(hash)
	end

	def self.find_or_create_by(hash)
		sql = "SELECT * FROM dogs WHERE name = '#{hash[:name]}' AND breed = '#{hash[:breed]}';"
		array = DB[:conn].execute(sql)
		hash2 = %w{}
		if array.count != 0
			array.each do |x| 
				hash2 = {
					:id => x[0], 
					:name => x[1], 
					:breed => x[2]
				}
			end
			self.new(hash2)
		else 
			self.create(hash)
		end
	end

	def self.new_from_db(array)
		hash = {
			:id => array[0], 
			:name => array[1], 
			:breed => array[2]
		}
		self.new(hash)
	end

	def self.find_by_name(name)
		sql = "SELECT * FROM dogs WHERE name = name"
		hash = %w{}
		DB[:conn].execute(sql).each do |x| 
			hash = {
				:id => x[0], 
				:name => x[1], 
				:breed => x[2]
			}
		end
		self.new(hash)
	end

	def update
		sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?;"
		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end


end
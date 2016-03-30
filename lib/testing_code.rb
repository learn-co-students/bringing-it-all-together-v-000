
require 'pry'
class Dog
	attr_accessor :name, :breed, :id
	def initialize(name:, breed:, id: 'string')

		@name = name
		@breed = breed
		@id = id
	end

	def self.create(name:, breed:)
		# binding.pry
		a = Dog.new(name: name , breed: breed)
		a
	end
end

# dog = Dog.new(name: "Fido", breed: "lab")
# # print dog.name
# print dog.id
b = Dog.create( name: "fido", breed: "pom")
print b.name

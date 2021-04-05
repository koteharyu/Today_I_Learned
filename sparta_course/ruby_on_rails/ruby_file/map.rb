class User
  attr_accessor :name
end

user1 = User.new
user1.name = "haryu"
user2 = User.new
user2.name = "saya"
user3 = User.new
user3.name = "kaka"

users = [user1, user2, user3]

names = []

names = users.map(&:name)

p names
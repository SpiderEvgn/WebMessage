# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

(1..9).each do |i|
  eval <<-USER
    User.create!(email:      "test0#{i}@webm.com",
                 username:   "test0#{i}",
                 password:   '111111'
                 )
  USER
end

User.first(5).each do |user|
  (1..5).each do |i|
    user.contacts.create!(contact_id: i)
  end
end

User.last(4).each do |user|
  (6..9).each do |i|
    user.contacts.create!(contact_id: i)
  end
end
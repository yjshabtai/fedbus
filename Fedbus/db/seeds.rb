# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

p1 = Permission.new
p1.name = 'Blackouts'
p1.save

p2 = Permission.new
p2.name = 'Buses'
p2.save

p3 = Permission.new
p3.name = 'Destinations'
p3.save

p4 = Permission.new
p4.name = 'Holidays'
p4.save

p5 = Permission.new
p5.name = 'Permissions'
p5.save

p6 = Permission.new
p6.name = 'Reading weeks'
p6.save

p7 = Permission.new
p7.name = 'Roles'
p7.save

p8 = Permission.new
p8.name = 'Tickets'
p8.save

p9 = Permission.new
p9.name = 'Trips'
p9.save

p10 = Permission.new
p10.name = 'Users'
p10.save

p11 = Permission.new
p11.name = 'Tickets sell'
p11.save

p12 = Permission.new
p12.name = 'Destruction'
p12.save

admin = Role.new
admin.name = 'Admin'
admin.permissions = Permission.all
admin.save

student = Role.new
student.name = 'Student'
student.save

vendor = Role.new
vendor.name = 'Vendor'
vendor.permissions << Permission.find_by_name('Tickets sell')
vendor.save

manager = Role.new
manager.name = 'Manager'
manager.permissions = Permission.all - [p5,p7,p12]
manager.save
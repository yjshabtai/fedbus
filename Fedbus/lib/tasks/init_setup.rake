desc "Setups permissions and roles"
task :init_setup => :environment do
	
	Permission.create(:name => "manage_access_control".humanize)
	puts "Permission manage_access_control created."
	
	Permission.create(:name => "tickets".humanize)
	puts "Permission tickets created."
	
	Permission.create(:name => "ticket_selling".humanize)
	puts "Permission ticket_selling created."
	
	Permission.create(:name => "destinations".humanize)
	puts "Permission destinations created."
	
	Permission.create(:name => "buses".humanize)
	puts "Permission buses created."
	
	Permission.create(:name => "trips".humanize)
	puts "Permission trips created."
	
	Permission.create(:name => "blackouts".humanize)
	puts "Permission blackouts created."
	
	Permission.create(:name => "holidays".humanize)
	puts "Permission holidays created."
	
	Permission.create(:name => "reading_weeks".humanize)
	puts "Permission reading_weeks created."
	
	Permission.create(:name => "invoices".humanize)
	puts "Permission invoices created."
	
	Permission.create(:name => "buses_admin".humanize)
	puts "Permission buses_admin created."
	
	Permission.create(:name => "admin".humanize)
	puts "Permission admin created."
	
	Permission.create(:name => "management".humanize)
	puts "Permission management created."
	
	adm = Role.new
	adm.name = "Admin"
	adm.permissions << Permission.all
	adm.save
	puts "Role Admin created. Has all permissions."

end
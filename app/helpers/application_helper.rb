module ApplicationHelper
	
	# TODO: This should probably go in the layout, or in a partial referenced from the layout
	# Generates the navigation bar, differing depending on user permissions
	def navbar
		curr_user = current_user
	
		html = ""
		html << '<ul class="navbar">'.html_safe
		
		if curr_user.has_permission?(:blackouts)
			html << '<li>'.html_safe
			html << (link_to "Blackouts", blackouts_path).html_safe
			html << '</li>'.html_safe
		end
		if curr_user.has_permission?(:buses)
			html << '<li>'.html_safe
			html << (link_to "Buses", buses_path).html_safe
			html << '</li>'.html_safe
		end
		if curr_user.has_permission?(:destinations)
			html << '<li>'.html_safe
			html << (link_to "Destinations", destinations_path).html_safe
			html << '</li>'.html_safe
		end
		if curr_user.has_permission?(:holidays)
			html << '<li>'.html_safe
			html << (link_to "Holidays", holidays_path).html_safe
			html << '</li>'.html_safe
		end
		if curr_user.has_permission?(:invoices)
			html << '<li>'.html_safe
			html << (link_to "Invoices", invoices_path).html_safe
			html << '</li>'.html_safe
		end
		if curr_user.has_permission?(:manage_access_control)
			html << '<li>'.html_safe
			html << (link_to "Permissions", permissions_path).html_safe
			html << '</li>'.html_safe
		end
		if curr_user.has_permission?(:reading_weeks)
			html << '<li>'.html_safe
			html << (link_to "Reading Weeks", reading_weeks_path).html_safe
			html << '</li>'.html_safe
		end
		if curr_user.has_permission?(:manage_access_control)
			html << '<li>'.html_safe
			html << (link_to "Roles", roles_path).html_safe
			html << '</li>'.html_safe
		end
		if curr_user.has_permission?(:tickets)
			html << '<li>'.html_safe
			html << (link_to "Tickets", tickets_path).html_safe
			html << '</li><li>'.html_safe
			html << (link_to "Ticket Logs", ticket_logs_path).html_safe
			html << '</li>'.html_safe
		end
		if curr_user.has_permission?(:trips)
			html << '<li>'.html_safe
			html << (link_to "Trips", trips_path).html_safe
			html << '</li>'.html_safe
		end
		if curr_user.has_permission?(:manage_access_control)
			html << '<li>'.html_safe
			html << (link_to "Users", users_path).html_safe
			html << '</li>'.html_safe
		end
		
		html << '<li>'.html_safe
		html << (link_to "My Profile", user_path(curr_user)).html_safe
		html << '</li>'.html_safe
		
		html << '<li>'.html_safe
		html << (link_to "My Cart", "/cart/" + curr_user.id.to_s).html_safe
		html << '</li>'.html_safe

		html << '<li>'.html_safe
		html << (link_to "Buy Tickets", tickets_buy_path).html_safe
		html << '</li>'.html_safe
		
		html << '</ul>'.html_safe
		html.html_safe
	
	end
	
	# TODO: I don't like the exposure of the "DESC".  It's not a necessarily bad thing, but it feels like it could be an injection vector
	# Creates the link for sorting a table by column
	def sort_table column, human_name, date_param = nil
		html = ""
		
		# if already sorting by this column then it reverses the sort
		if (request.url.include? column) && !(request.url.include? "DESC")
			if date_param
				# TODO: Return from this depth, makes for a simpler function
				html << (link_to human_name, :sort => column + " DESC", :date => date_param).html_safe
			else
				html << (link_to human_name, :sort => column + " DESC").html_safe
			end
		else
			if date_param
				html << (link_to human_name, :sort => column, :date => date_param).html_safe
			else
				html << (link_to human_name, :sort => column).html_safe
			end
		end
		
		html.html_safe
	end
	
	# TODO: This should probably also be in a partial, sort_table might make sense to stay here
	# Creates the interface panel for viewing data on models
	def create_table objects, columns, title, date_param = nil, nosort = false
		curr_user = current_user
	
		id_to_names = ["trip_id","destination_id","bus_id"]
		times = ["depart_time","arrive_time","return_time"]
		dates = ["date","start","expiry","offset_date","start_date","end_date","created_at","updated_at"]
		no_management = ["permissions", "roles"]
		management_headers = ["updated_by","created_at","updated_at"]
		
		html = ""
		html << '<h1>'.html_safe
		html << title
		
		html << '</h1>'.html_safe
		
		html << '<table class="admin_table">'.html_safe
		
		html << '<tr class="tr_header">'.html_safe
		columns.each do |col|
			
			col_title = col
			
			if col.include? '_id' then col_title = col.split('_id')[0] end
			
			if management_headers.include? col
				if curr_user.has_permission? :management
					html << '<th>'.html_safe
					if !nosort 
						html << sort_table(col, col_title.humanize, date_param).html_safe
					else
						html << col_title.humanize
					end
					html << '</th>'.html_safe
				end
			else
				html << '<th>'.html_safe
				if !nosort 
					html << sort_table(col, col_title.humanize, date_param).html_safe
				else
					html << col_title.humanize
				end
				html << '</th>'.html_safe
			end
			
		end
		
		# Show Column
		html << '<th></th>'.html_safe
		
		# Edit Column
		if (curr_user.has_permission? :admin) || (!(no_management.include? objects[0].class.name.tableize) && (curr_user.has_permission? :management))
			html << '<th></th>'.html_safe
		end
		
		# Destroy Column
		if curr_user.has_permission? :admin
			html << '<th></th>'.html_safe
		end
		
		html << '</tr>'.html_safe
		
		i = 0
		objects.each do |obj|
			if i.even?
				html << '<tr class="tr_alt_1">'.html_safe
			else
				html << '<tr class="tr_alt_2">'.html_safe
			end
				columns.each do |col|
					
					if id_to_names.include? col
						html << '<td>'.html_safe
						col = col.split('_id')[0]
						html << (link_to obj.send(col).id.to_s + ": " + obj.send(col).name, obj.send(col)).html_safe
					elsif col == "user_id" || col == "updated_by"
						html << '<td>'.html_safe
						col = col.split('_id')[0]
						if obj.send(col)
							html << (link_to obj.send(col).userid, obj.send(col)).html_safe
						end
					elsif col == "id"
						html << '<td class="td_links">'.html_safe
						html << obj.send(col).to_s
					elsif col == "weekday"
						html << '<td>'.html_safe
						html << Date::DAYNAMES[obj.send(col)]
					elsif times.include? col
						html << '<td>'.html_safe
						html << obj.send(col).strftime("%I:%M %p")
					elsif dates.include? col
						html << '<td>'.html_safe
						html << obj.send(col).strftime("%B %d, %Y")
					elsif col.include? "_id"
						html << '<td>'.html_safe
						col = col.split('_id')[0]
						if obj.send(col)
							html << (link_to obj.send(col).id.to_s, obj.send(col)).html_safe
						end
					else
						html << '<td>'.html_safe
						html << obj.send(col).to_s
					end
					
					html << '</td>'.html_safe
				end
				
				# Show Column
				html << '<td class="td_links">'.html_safe
				html << (link_to "Show", obj).html_safe
				html << '</td>'.html_safe
				
				# Edit Column
				if (curr_user.has_permission? :admin) || (!(no_management.include? objects[0].class.name.tableize) && (curr_user.has_permission? :management))
					html << '<td class="td_links">'.html_safe
					html << (link_to "Edit", "/" + obj.class.name.tableize + "/" + obj.id.to_s + "/edit").html_safe
					html << '</td>'.html_safe
				end
				
				# Destroy Column
				if curr_user.has_permission? :admin
					html << '<td class="td_links">'.html_safe
					html << (link_to "Destroy", obj, :confirm => 'Are you sure?', :method => :delete).html_safe
					html << '</td>'.html_safe
				end
		
			html << '</tr>'.html_safe
			i = i + 1
		end
		
		html << '</table>'.html_safe
		
		html.html_safe
	end
	
	# TODO: Again, good candidate for a partial
	# Creates search forms for a Model type
	def search_form objs_type, searches
		
		dates = ["date","created_at","updated_at"]
		times = ["depart_time","arrive_time","return_time"]
		selections = ["trip_id","destination_id"]
		
		html = ""
		
		html << '<table><tr><th></th><th></th><th></th></tr>'.html_safe
		
		searches.each do |search|
		
			html << '<form accept-charset="UTF-8" action="/'.html_safe + objs_type + '" method="get">'.html_safe
			html << '<tr><td>'.html_safe
		
			if dates.include? search
				html << (label_tag(search + "1", "Search for " + objs_type + " with " + search + " between ")).html_safe
				html << '</td><td>'.html_safe
				html << (date_select(search, "1")).html_safe
				html << (label_tag(search + "2", " and ")).html_safe
				html << (date_select(search, "2")).html_safe
			else
				html << (label_tag(search, "Search for " + objs_type + " with " + search + ": ")).html_safe
				html << '</td><td>'.html_safe
				html << (text_field_tag(search)).html_safe
			end
			
			html << '</td><td>'.html_safe
			html << (submit_tag("Search")).html_safe
			html << '</td>'.html_safe
			
			html << '</tr>'.html_safe
			html << '</form>'.html_safe
		end
		
		html << '</table>'.html_safe
		
		html.html_safe
	end

end

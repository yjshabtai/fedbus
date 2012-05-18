ActiveAdmin.register Bus do
#scope :open
#scope :locked
	# Generates the right actions for the current user based on permissions
  controller do
  	def action_methods
  		cu = current_user

  		['index', 'show'] +
  		(cu.has_permission?(:buses) ? ['create','new','edit','update'] : []) +
  		(cu.has_permission?(:destruction) ? ['destroy'] : [])
  	end

    # Replacing create controller so that protected attrs can be mass assigned by someone with the right permission
    def create
      @bus = Bus.new
      if current_user.has_permission?(:buses)
        @bus.accessible = :all
      end
      @bus.update_trip_info Trip.find(params[:bus][:trip_id])

      respond_to do |format|
        if @bus.update_attributes(params[:bus])
          format.html { redirect_to [:admin, @bus], :notice => "Bus was successfully created." }
        else
          flash[:error] = "Bus was not created."
          format.html { render active_admin_template(:new) }
        end
      end
    end

    # Replacing update controller so that protected attrs can be mass assigned by someone with the right permission
    def update
      @bus = Bus.find(params[:id])
      if current_user.has_permission?(:buses)
        @bus.accessible = :all
      end

      respond_to do |format|
        if @bus.update_attributes(params[:bus])
          format.html { redirect_to [:admin, @bus], :notice => "Bus was successfully updated." }
        else
          flash[:error] = "Bus was not updated."
          format.html { render active_admin_template(:edit) }
        end
      end
    end
  end


  # Customizes what appears on the index page
  index do
    column :name, :sortable => :name do |bus|
        link_to bus.name, [:admin, bus]
    end
    column :date
    column :direction
    column :status, :sortable => :status do |stat|
    	status_tag(stat.status, :class => (stat.status == 'open' ? 'completed' : 'active'))
    end
    column :created_at
    column :updated_at
    default_actions
  end

  # Customizes what appears on the show page
  show do |bus|
    attributes_table do
      row :id
      row :name
      row :description
      row :trip
      row :destination
      row :date
      row :depart_time do
        bus.depart_time.strftime("%H:%M")
      end
      row :arrive_time do
        bus.arrive_time.strftime("%H:%M")
      end
      row :return_time do
        bus.return_time.strftime("%H:%M")
      end
      row :direction
      row :status
      row :ticket_price
      row :sales_lead
      row :maximum_seats
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

   # Creates a sidebar that displays the destination's trips
  sidebar :info, :only => :show do
    #table_for tickets.trips do
    #    column :name do |trip|
    #      link_to trip.name, [:admin, trip]
    #    end
    #end
  end


  # Customizes the form for editing/creating
  form do |f|
  	if !f.object.new_record?
  			f.inputs "Details" do
	  		f.input :name
	  		f.input :description
	  	end
	end
  	f.inputs "Trip Info" do
  		f.input :trip
  		f.input :date
  		f.input :direction, :as => :radio, :collection => [['Both Directions', :both_directions], ['From Waterloo', :from_waterloo], ['To Waterloo', :to_waterloo]]
  		f.input :status, :as => :radio, :collection => [:open, :locked]
  		f.input :maximum_seats
    end
  	if !f.object.new_record?
  		f.inputs "Change Trip Specs" do
	  		f.input :depart_time
	  		f.input :arrive_time
	  		f.input :return_time
	  		f.input :ticket_price
	  		f.input :sales_lead
  		end
    end
  	f.buttons
  end


  # Filters for searching
  filter :name
  filter :trip
  filter :destination
  filter :date
  filter :status, :as => :select, :collection => ['open','locked']
  filter :direction, :as => :select, :collection => ['both_directions','from_waterloo','to_waterloo']
  filter :ticket_price
  filter :sales_lead
  filter :maximum_seats
  filter :created_at
  filter :updated_at

end

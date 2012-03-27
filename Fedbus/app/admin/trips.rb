ActiveAdmin.register Trip do

	# Generates the right actions for the current user based on permissions
  controller do
  	def action_methods
  		cu = current_user

  		['index', 'show'] +
  		(cu.has_permission?(:trips) ? ['create','new','edit','update'] : []) +
  		(cu.has_permission?(:destruction) ? ['destroy'] : [])
  	end

    # Replaces new controller so that the time fields are defaulted because the Ruby Time class includes the date too.
    def new
      @trip = Trip.new
      @trip.depart_time = Time.at(0)
      @trip.arrive_time = Time.at(0)
      @trip.return_time = Time.at(0)
    end

    # Replacing create controller so that protected attrs can be mass assigned by someone with the right permission
    def create
      @trip = Trip.new
      if current_user.has_permission?(:trips)
        @trip.accessible = :all
      end

      respond_to do |format|
        if @trip.update_attributes(params[:trip])
          format.html { redirect_to [:admin, @trip], :notice => "Trip was successfully created." }
        else
          flash[:error] = "Trip was not created."
          format.html { render active_admin_template(:new) }
        end
      end
    end

    # Replacing update controller so that protected attrs can be mass assigned by someone with the right permission
    def update
      @trip = Trip.find(params[:id])
      if current_user.has_permission?(:trips)
        @trip.accessible = :all
      end

      respond_to do |format|
        if @trip.update_attributes(params[:trip])
          format.html { redirect_to [:admin, @trip], :notice => "Trip was successfully updated." }
        else
          flash[:error] = "Trip was not updated."
          format.html { render active_admin_template(:edit) }
        end
      end
    end
  end

  # Customizes what appears on the index page
  index do
    column :name, :sortable => :name do |trip|
        link_to trip.name, [:admin, trip]
    end
    column :destination, :sortable => :destination_id
    column :weekday, :sortable => :weekday do |trip|
      Date::DAYNAMES[trip.weekday]
    end
    column :depart_time, :sortable => :depart_time do |trip|
      trip.depart_time.strftime("%H:%M")
    end
    column :arrive_time, :sortable => :arrive_time do |trip|
      trip.arrive_time.strftime("%H:%M")
    end
    column :return_time, :sortable => :return_time do |trip|
      trip.return_time.strftime("%H:%M")
    end
    column :created_at
    column :updated_at
    default_actions
  end

  # Customizes what appears on the show page
  show :title => :name do |trip|
    attributes_table do
      row :name
      row :destination
      row :weekday do
        Date::DAYNAMES[trip.weekday]
      end
      row :depart_time do
        trip.depart_time.strftime("%H:%M")
      end
      row :arrive_time do
        trip.arrive_time.strftime("%H:%M")
      end
      row :return_time do
        trip.return_time.strftime("%H:%M")
      end
      row :ticket_price
      row :sales_lead
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  # Sidebar table of recent buses for this trip.
  sidebar "Recent Buses", :only => :show do
    table_for Bus.where(:trip_id => trip.id).order("date desc").limit(15) do
      column :name, :sortable => :name do |bus|
        link_to bus.name, [:admin, bus]
      end
      column :date
    end
  end

  # Customizes the form for editing/creating
  form do |f|
  	f.inputs "Details" do
  		f.input :name
  		f.input :destination
  		f.input :weekday, :as => :select, :collection => [['Sunday',0],['Monday',1],['Tuesday',2],['Wednesday',3],['Thursday',4],['Friday',5],['Saturday',6]]
  		f.input :depart_time
  	  f.input :arrive_time
  		f.input :return_time
      f.input :ticket_price
      f.input :sales_lead
    end

  	f.buttons
  end


  # Filters for searching
  filter :name
  filter :destination
  filter :weekday, :as => :select, :collection => [['Sunday',0],['Monday',1],['Tuesday',2],['Wednesday',3],['Thursday',4],['Friday',5],['Saturday',6]]
  filter :ticket_price
  filter :sales_lead
  filter :created_at
  filter :updated_at
end

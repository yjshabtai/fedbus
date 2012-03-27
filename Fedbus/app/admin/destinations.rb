ActiveAdmin.register Destination do

  # Generates the right actions for the current user based on permissions
  controller do
  	def action_methods
  		cu = current_user

  		['index', 'show'] +
  		(cu.has_permission?(:destinations) ? ['create','new','edit','update'] : []) +
  		(cu.has_permission?(:destruction) ? ['destroy'] : [])
  	end

    # Replacing create controller so that protected attrs can be mass assigned by someone with the right permission
    def create
      @destination = Destination.new
      if current_user.has_permission?(:destinations)
        @destination.accessible = :all
      end

      respond_to do |format|
        if @destination.update_attributes(params[:destination])
          format.html { redirect_to [:admin, @destination], :notice => "Destination was successfully created." }
        else
          flash[:error] = "Destination was not created."
          format.html { render active_admin_template(:new) }
        end
      end
    end

    # Replacing update controller so that protected attrs can be mass assigned by someone with the right permission
    def update
      @destination = Destination.find(params[:id])
      if current_user.has_permission?(:destinations)
        @destination.accessible = :all
      end

      respond_to do |format|
        if @destination.update_attributes(params[:destination])
          format.html { redirect_to [:admin, @destination], :notice => "Destination was successfully updated." }
        else
          flash[:error] = "Destination was not updated."
          format.html { render active_admin_template(:edit) }
        end
      end
    end
  end

  # Customizes what appears on the index page
  index do
    column :name do |dest|
        link_to dest.name, [:admin, dest]
    end
    column :created_at
    column :updated_at
    default_actions
  end

  # Customizes what appears on the show page
  show :title => :name do |dest|
    attributes_table do
      row :name
      row :description
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

   # Creates a sidebar that displays the destination's trips
  sidebar :trips, :only => :show do
    table_for destination.trips do
        column :name do |trip|
          link_to trip.name, [:admin, trip]
        end
    end
  end


  # Customizes the form
  form do |f|
  	f.inputs "Details" do
  		f.input :name
  		f.input :description
  	end
  	f.buttons
  end

end

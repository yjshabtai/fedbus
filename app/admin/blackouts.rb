ActiveAdmin.register Blackout do
  menu :parent => "Holidays"
	
  # Generates the right actions for the current user based on permissions
  controller do
  	def action_methods
  		cu = current_user

  		['index', 'show'] +
  		(cu.has_permission?(:blackouts) ? ['create','new','edit','update'] : []) +
  		(cu.has_permission?(:destruction) ? ['destroy'] : [])
  	end

    # Replacing create controller so that protected attrs can be mass assigned by someone with the right permission
    def create
      @blackout = Blackout.new
      if current_user.has_permission?(:blackouts)
        @blackout.accessible = :all
      end

      respond_to do |format|
        if @blackout.update_attributes(params[:blackout])
          format.html { redirect_to [:admin, @blackout], :notice => "Blackout was successfully created." }
        else
          flash[:error] = "Blackout was not created."
          format.html { render active_admin_template(:new) }
        end
      end
    end

    # Replacing update controller so that protected attrs can be mass assigned by someone with the right permission
    def update
      @blackout = Blackout.find(params[:id])
      if current_user.has_permission?(:blackouts)
        @blackout.accessible = :all
      end

      respond_to do |format|
        if @blackout.update_attributes(params[:blackout])
          format.html { redirect_to [:admin, @blackout], :notice => "Blackout was successfully updated." }
        else
          flash[:error] = "Blackout was not updated."
          format.html { render active_admin_template(:edit) }
        end
      end
    end
  end

  # Customizes what appears on the index page
  index do
  	column :id, :sortable => :id do |bo|
  		link_to bo.id, [:admin, bo]
  	end
    column :start
    column :expiry
    column :created_at
    column :updated_at
    default_actions
  end
end

ActiveAdmin.register ReadingWeek do
  menu :parent => "Holidays"
	
  # Generates the right actions for the current user based on permissions
  controller do
  	def action_methods
  		cu = current_user

  		['index', 'show'] +
  		(cu.has_permission?(:reading_weeks) ? ['create','new','edit','update'] : []) +
  		(cu.has_permission?(:destruction) ? ['destroy'] : [])
  	end

    # Replacing create controller so that protected attrs can be mass assigned by someone with the right permission
    def create
      @reading_week = ReadingWeek.new
      if current_user.has_permission?(:reading_weeks)
        @reading_week.accessible = :all
      end

      respond_to do |format|
        if @reading_week.update_attributes(params[:reading_week])
          format.html { redirect_to [:admin, @reading_week], :notice => "Reading Week was successfully created." }
        else
          flash[:error] = "Reading Week was not created."
          format.html { render active_admin_template(:new) }
        end
      end
    end

    # Replacing update controller so that protected attrs can be mass assigned by someone with the right permission
    def update
      @reading_week = ReadingWeek.find(params[:id])
      if current_user.has_permission?(:reading_weeks)
        @reading_week.accessible = :all
      end

      respond_to do |format|
        if @reading_week.update_attributes(params[:reading_week])
          format.html { redirect_to [:admin, @reading_week], :notice => "Reading Week was successfully updated." }
        else
          flash[:error] = "Reading Week was not updated."
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
    column :start_date
    column :end_date
    column :created_at
    column :updated_at
    default_actions
  end
end

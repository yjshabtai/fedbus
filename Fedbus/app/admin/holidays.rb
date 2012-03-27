ActiveAdmin.register Holiday do
	
  # Generates the right actions for the current user based on permissions
  controller do
  	def action_methods
  		cu = current_user

  		['index', 'show'] +
  		(cu.has_permission?(:holidays) ? ['create','new','edit','update'] : []) +
  		(cu.has_permission?(:destruction) ? ['destroy'] : [])
  	end

    # Replacing create controller so that protected attrs can be mass assigned by someone with the right permission
    def create
      @holiday = Holiday.new
      if current_user.has_permission?(:holidays)
        @holiday.accessible = :all
      end

      respond_to do |format|
        if @holiday.update_attributes(params[:holiday])
          format.html { redirect_to [:admin, @holiday], :notice => "Holiday was successfully created." }
        else
          flash[:error] = "Holiday was not created."
          format.html { render active_admin_template(:new) }
        end
      end
    end

    # Replacing update controller so that protected attrs can be mass assigned by someone with the right permission
    def update
      @holiday = Holiday.find(params[:id])
      if current_user.has_permission?(:holidays)
        @holiday.accessible = :all
      end

      respond_to do |format|
        if @holiday.update_attributes(params[:holiday])
          format.html { redirect_to [:admin, @holiday], :notice => "Holiday was successfully updated." }
        else
          flash[:error] = "Holiday was not updated."
          format.html { render active_admin_template(:edit) }
        end
      end
    end
  end

  # Customizes what appears on the index page
  index do
    column :name do |hol|
        link_to hol.name, [:admin, hol]
    end
    column :date
    column :offset_date
    column :created_at
    column :updated_at
    default_actions
  end

  # Customizes what appears on the show page
  show :title => :name do |dest|
    attributes_table do
      row :name
      row :date
      row :offset_date
      row :comment
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end

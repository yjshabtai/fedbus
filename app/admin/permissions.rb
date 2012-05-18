ActiveAdmin.register Permission do
  menu :parent => "Users"

  # Customizes the controller
  controller do
  	# Generates the right actions for the current user based on permissions
  	def action_methods
  		cu = current_user

  		['index', 'show'] +
  		(cu.has_permission?(:permissions) ? ['create','new','edit','update'] : []) +
  		(cu.has_permission?(:destruction) ? ['destroy'] : [])
  	end

    # Replacing create controller so that protected attrs can be mass assigned by someone with the right permission
    def create
      @permission = Permission.new
      if current_user.has_permission?(:permissions)
        @permission.accessible = :all
      end

      respond_to do |format|
        if @permission.update_attributes(params[:permission])
          format.html { redirect_to [:admin, @permission], :notice => "Permission was successfully created." }
        else
          flash[:error] = "Permission was not created."
          format.html { render active_admin_template(:new) }
        end
      end
    end

    # Replacing update controller so that userid can be mass assigned by someone with the 'users' permission
    def update
      @permission = Permission.find(params[:id])
      if current_user.has_permission?(:permissions)
        @permission.accessible = :all
      end

      respond_to do |format|
        if @permission.update_attributes(params[:permission])
          format.html { redirect_to [:admin, @permission], :notice => "Permission was successfully updated." }
        else
          flash[:error] = "Permission was not updated."
          format.html { render active_admin_template(:edit) }
        end
      end
    end
  end


  # Customizes what appears on the index page
  index do
    column :name do |perm|
        link_to perm.name, [:admin, perm]
    end
    column :created_at
    column :updated_at
    default_actions
  end

  # Customizes what appears on the show page
  show :title => :name do |perm|
    attributes_table do
      row :name
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  # Creates a sidebar that displays the permission's roles
  sidebar :roles, :only => :show do
    table_for permission.roles do
        column :name do |role|
          link_to role.name, [:admin, role]
        end
    end
  end


  # Customizes the form for editing/creating
  form do |f|
  	f.inputs "Details" do
	  	f.input :name
	    f.input :roles, :as => :check_boxes
	end
  	f.buttons
  end
end

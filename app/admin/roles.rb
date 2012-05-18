ActiveAdmin.register Role do
  menu :parent => "Users"

  # Customizes the controller
  controller do
  	# Generates the right actions for the current user based on permissions
  	def action_methods
  		cu = current_user

  		['index', 'show'] +
  		(cu.has_permission?(:roles) ? ['create','new','edit','update'] : []) +
  		(cu.has_permission?(:destruction) ? ['destroy'] : [])
  	end

    # Replacing create controller so that protected attrs can be mass assigned by someone with the right permission
    def create
      @role = Role.new
      if current_user.has_permission?(:roles)
        @role.accessible = :all
      end

      respond_to do |format|
        if @role.update_attributes(params[:role])
          format.html { redirect_to [:admin, @role], :notice => "Role was successfully created." }
        else
          flash[:error] = "Role was not created."
          format.html { render active_admin_template(:new) }
        end
      end
    end

    # Replacing update controller so that protected attrs can be mass assigned by someone with the right permission
    def update
      @role = Role.find(params[:id])
      if current_user.has_permission?(:roles)
        @role.accessible = :all
      end

      respond_to do |format|
        if @role.update_attributes(params[:role])
          format.html { redirect_to [:admin, @role], :notice => "Role was successfully updated." }
        else
          flash[:error] = "Role was not updated."
          format.html { render active_admin_template(:edit) }
        end
      end
    end
  end


  # Customizes what appears on the index page
  index do
    column :name do |role|
        link_to role.name, [:admin, role]
    end
    column :created_at
    column :updated_at
    default_actions
  end

  # Customizes what appears on the show page
  show :title => :name do |user|
    attributes_table do
      row :name
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  # Creates a sidebar that displays the role's permissions
  sidebar :permissions, :only => :show do
    table_for role.permissions do
        column :name do |perm|
          link_to perm.name, [:admin, perm]
        end
    end
  end

  # Creates a sidebar that displays the role's users
  sidebar :users, :only => :show do
    table_for role.users do
        column :user do |user|
          link_to user.email, [:admin, user]
        end
    end
  end


  # Customizes the form for editing/creating
  form do |f|
  	f.inputs "Details" do
	  	f.input :name
	    f.input :permissions, :as => :check_boxes
	end
  	f.buttons
  end
end

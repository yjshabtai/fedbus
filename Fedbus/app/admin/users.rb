ActiveAdmin.register User do
	  
  # Customizes the controller
  controller do
    # Generates the right actions for the current user based on permissions
    def action_methods
  		cu = current_user

  		['index', 'show'] +
  		(cu.has_permission?(:users) ? ['create','new','edit','update'] : []) +
  		(cu.has_permission?(:destruction) ? ['destroy'] : [])
  	end

    # Replacing create controller so that userid can be mass assigned by someone with the 'users' permission
    def create
      @user = User.new
      cu = current_user

      # If the current user has permissions to sell tickets but not any more than the created user must be a student
      if cu.has_permission?(:users)
        @user.accessible = :all
      end

      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to [:admin, @user], :notice => "User was successfully created." }
        else
          flash[:error] = "User was not created."
          format.html { render active_admin_template(:new) }
        end
      end
    end

    # Replacing update controller so that userid can be mass assigned by someone with the 'users' permission
    def update
      @user = User.find(params[:id])
      if current_user.has_permission?(:users)
        @user.accessible = :all
      end

      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to [:admin, @user], :notice => "User was successfully updated." }
        else
          flash[:error] = "User was not updated."
          format.html { render active_admin_template(:edit) }
        end
      end
    end
  end

  # Customizes what appears on the index page
  index do
    column :userid do |user|
        link_to user.userid, [:admin, user]
    end
    column :first_name
    column :last_name
    column :email
    default_actions
  end

  # Customizes what appears on the show page
  show do |user|
    attributes_table do
      row :userid
      row :first_name
      row :last_name
      row :email
      row :created_at
    end

    active_admin_comments
  end

  # Creates a sidebar that displays the user's roles
  sidebar :roles, :only => :show do
    table_for user.roles do
        column :name do |role|
          link_to role.name, [:admin, role]
        end
    end
  end


  # Customizes the form for editing/creating
  form do |f|
    cu = current_user

  	f.inputs "Details" do
  		f.input :first_name
  		f.input :last_name
  		f.input :email
    end
    f.inputs "Identification" do
  		f.input :student_number
  		f.input :student_number_confirmation
      f.input :userid
  	end

    # Allows someone with roles permission (the admin) to assign roles to others
    if cu.has_permission?(:roles)
      f.inputs "Permissions" do
        f.input :roles, :as => :check_boxes
      end
    end

  	f.buttons
  end
  
  

  # Filters for searching users
  filter :first_name
  filter :last_name
  filter :email
  filter :userid
  filter :roles_name, :as => :string, :label => 'Role Name'
  filter :created_at
  filter :updated_at
end

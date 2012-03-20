ActiveAdmin.register User do
  index do
    column :first_name
    column :last_name
    column :email
    column :last_sign_in_at
    default_actions
  end

	form do |f|
		f.inputs "User Details" do
			f.inputs :email
			f.inputs :password
			f.inputs :first_name
			f.inputs :last_name
			f.inputs :user_type
		end
		f.buttons
	end

	def password_required?
	  new_record? ? false : super
	end	
end

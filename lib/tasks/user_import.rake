task :user_import => :environment do
	@all_users = AuthProvider.get_all_devise_users
	@all_users.each do |u|
		User.transaction do
			user = User.new
			user.id = u['id']
			user.email = u['email']
			user.password = "THISISAFAKEPW"
			user.password_confirmation = "THISISAFAKEPW"
			user.encrypted_password = u['encrypted_password']
			user.first_name = u['first_name']
			user.last_name = u['last_name']
			user.school = u['school']
			user.user_token = u['user_token']
			user.user_type = u['user_type']
			user.save!
			puts user.to_json
		end
	end
end
namespace :db do
  task :setup => :environment do
    tasks = ["create_admin"]

    tasks.each_with_index do |task, index|
      puts "preparing..."
      puts "#{index + 1}. #{task}"

      Rake::Task["app:#{task}"].execute
    end
  end

  desc 'Create admin user'
  task :create_admin => :environment do
    print "-----> working..."
    ActiveRecord::Base.transaction do
      admin = {
        :username => 'admin',
        :email    => 'admin@ideation.is',
        :password => 'admin@al',
        :password_confirmation => 'admin@al'
      }

      admin = Refinery::User.create!(admin)
      print '.'

      admin.add_role('refinery')
      admin.add_role('superuser')
      print '.'

      puts
    end
  end
end

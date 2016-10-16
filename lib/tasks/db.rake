require 'rake'
require 'colorize'
require 'rake-progressbar'
require 'mysql_to_pg_dump/tasks_helper'

namespace :db do
  include MysqlToPgDump::TasksHelper

  desc "Copies db content from production " \
       "server into tmp/db_server_data"
  task pull: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    server_addr =
      ARGV[1].blank? ? server_addr_input : ARGV[1].to_s

    if server_addr.include?("@")
      bar = RakeProgressbar.new(db_tables.size)
      tmp_location = uniq_dir_location

      system "ssh #{server_addr} 'mkdir -p #{tmp_location}'"
      db_tables.each do |table|
        system %{ssh #{server_addr} "echo '#{sql_select(table)}' | #{login_to_mysql} > #{file_to_save(table, tmp_location)}"}
        bar.inc
      end
      bar.finished

      system "scp -r #{server_addr}:#{tmp_location}/* tmp/db_server_data"
      system "ssh #{server_addr} 'rm -rf #{tmp_location}'"

      printf "Db data from production server " \
             "has been pulled successfully\n".green
    else
      printf "No server address given." \
             "Expecting format like 'server@123.4.5.6'\n".yellow
    end
  end

  namespace :pull do
    desc "Replaces current db data to pulled"
    task load: :environment do
      printf "Current env db data will be destroyed.\n".red
      printf "Are you sure? (y/n)\n"
      confirm_input = STDIN.gets.strip

      if confirm_input == 'y'
        if data_already_pulled?
          clean_database
          db_tables.each do |t|
            system %(psql -d #{dev['database']} -c "#{psql_import_query(t)} #{psql_set_sequence(t)}")
          end
          printf "Your db data now is equal to production\n".green
        else
          printf "No pulled data. Run 'rake db:pull' first\n".yellow
        end
      else
        printf "Canceled\n".blue
      end
    end

    desc "Deletes pulled db data from local tmp/db_server_data"
    task :clean do
      system 'rm -f tmp/db_server_data/*'
      printf "Pulled db data has been " \
             "deleted from /tmp successfully\n".green
    end

    desc "Pulls remote mysql db data and loads it to local psql"
    task reload: ['db:pull', 'db:pull:load']

    desc "Pulls remote mysql db data, then loads it to " \
         "local postgres and cleans junk"
    task force: ['db:pull:reload', 'db:pull:clean']
  end
end

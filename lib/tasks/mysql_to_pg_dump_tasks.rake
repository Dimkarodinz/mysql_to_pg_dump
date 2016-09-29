require 'colorize'

include MysqlToPgDump::RakeHelper
namespace :db do
  desc "Copies db content from production " \
       "server into tmp/db_server_data"
  task pull: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    server_addr =
      ARGV[1].blank? ? server_addr_input : ARGV[1].to_s

    if server_addr.include?("@")
      bar = RakeProgressbar.new(db_tables.size)
      system mk_server_tmp_storage_dir(server_addr)

      db_tables.each do |table|
        system %{ssh #{server_addr} "echo '#{sql_select(table)}' | #{mysql_login} > #{file_to_save(table)}"}
        bar.inc
      end
      bar.finished

      system copy_db_data_to_local(server_addr)
      system del_server_tmp_storage_dir(server_addr)

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
      input = STDIN.gets.strip

      if input == 'y'
        if data_pulled?
          clear_db
          db_tables.each { |t| system %(psql -d #{dev['database']} -c "#{psql_query(t)}") }
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

    desc "Pulls remote mysql db data, then loads it to " \
         "local postgres and cleans junk"
    task force: ['db:pull', 'db:pull:load', 'db:pull:clean']
  end
end

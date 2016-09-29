module MysqlToPgDump
  module RakeHelper
    def server_addr_input
      printf "Enter server address like 'server@123.4.5.6': "
      STDIN.gets.strip
    end

    def data_pulled?
      if %x(ls tmp).split("\n").include? 'db_server_data'
        %x(ls tmp/db_server_data).split("\n").size == db_tables.size
      else
        false
      end
    end

    def psql_query table_name
      "\\copy #{table_name} from " \
      "'tmp/db_server_data/#{production['database']}_#{table_name}.txt' " \
      "delimiter E'\\t' null as 'NULL' csv header"
    end

    def clear_db
      task_names = %w(db:drop db:create db:migrate)
      task_names.each { |t| Rake::Task[t].invoke }
    end

    def dev
      show_db_info 'development'
    end

    def production
      show_db_info 'production'
    end

    def show_db_info env
      Rails.application.config.database_configuration[env]
    end

    def copy_db_data_to_local server_address
      "scp -r #{server_address}:#{tmp_location} tmp"
    end

    def mysql_login
      "mysql " \
      "--user=#{production['username']} " \
      "--password=#{production['password']} " \
      "#{production['database']}"
    end

    def file_to_save table_name
      "#{tmp_location}/#{production['database']}_#{table_name}.txt"
    end

    def sql_select table_name
      "SELECT * FROM #{table_name};"
    end

    def db_tables
      ActiveRecord::Base.connection.tables - ['schema_migrations']
    end

    def mk_server_tmp_storage_dir server_address
      "ssh #{server_address} mkdir -p #{tmp_location}"
    end

    def del_server_tmp_storage_dir server_address
      "ssh #{server_address} 'rm -rf #{tmp_location}'"
    end

    def tmp_location
      'app/current/tmp/db_server_data'
    end
  end
end

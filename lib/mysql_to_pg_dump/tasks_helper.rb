require 'mysql_to_pg_dump'

module MysqlToPgDump
  module TasksHelper
    def server_addr_input
      printf "Enter server address like 'server@123.4.5.6': "
      STDIN.gets.strip
    end

    def data_already_pulled?
      if %x{ls tmp}.split("\n").include? 'db_server_data'
        %x(ls tmp/db_server_data).split("\n").size == db_tables.size
      else
        false
      end
    end

    def psql_import_query table_name
      "\\copy #{table_name} from " \
      "'tmp/db_server_data/#{production['database']}_#{table_name}.csv' " \
      "delimiter E'\\t' null as 'NULL' csv header"
    end

    def clean_database
      task_names = %w(db:drop db:create db:migrate)
      task_names.each { |t| Rake::Task[t].invoke }
    end

    def login_to_mysql
      "mysql " \
      "--user=#{production['username']} " \
      "--password=#{production['password']} " \
      "#{production['database']}"
    end

    def file_to_save table_name, location
      "#{location}/#{production['database']}_#{table_name}.csv"
    end

    def sql_select table_name
      "SELECT * FROM #{table_name};"
    end

    def db_tables
      ActiveRecord::Base.connection.tables - ['schema_migrations']
    end

    def uniq_dir_location
      "app/current/tmp/db_server_data/#{uniq_string}"
    end

    def uniq_string
      s = ""
      20.times { s << ('0'..'9').to_a.sample }
      s
    end

    def show_db_info env
      Rails.application.config.database_configuration[env]
    end

    def dev
      show_db_info 'development'
    end

    def production
      show_db_info 'production'
    end
  end
end
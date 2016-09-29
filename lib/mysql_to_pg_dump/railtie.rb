require 'mysql_to_pg_dump'
require 'rails'

module MysqlToPgDump
  class Railtie < Rails::Railtie
    rake_tasks do
      require '../tasks/db.rake'
    end
  end
end
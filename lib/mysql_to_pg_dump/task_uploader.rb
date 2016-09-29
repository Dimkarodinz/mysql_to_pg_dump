require 'mysql_to_pg_dump'
require 'rails'

module MysqlToPgDump
  module TaskUploader
    spec = Gem::Specification.find_by_name 'mysql_to_pg_dump'
    load "#{spec.gem_dir}/lib/tasks/db.rake"
  end
end
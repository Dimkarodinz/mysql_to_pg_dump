# MysqlToPgDump
This gem allows pull content from mysql db (on the remote server) and
load it into your local postgres database.
Technically, it is not a dump - but result is almost the same. 

## Usage
Copy content of remote mysql db to tmp/db_server_data as .csv files.
```bash
$ rake db:pull your_server@123.4.5.6
```
Replace local postgres db content to pulled.
```bash
$ rake db:pull:load
 # or
$ RAILS_ENV=staging rake db:pull:load
```
Delete all files from tmp/db_server_data.
```bash
$ rake db:pull:clean
```
Pull remote mysql db data and then loads it to local postgres db.
Same as `db:pull` and `db:pull:load`
```bash
$ rake db:pull:reload
```
Pull remote mysql db data, load it to postgres db and clean junk from /tmp/db_server_data. Same as `db:pull`, `db:pull:load` and `db:pull:clean`.
```bash
$ rake db:pull:force
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'mysql_to_pg_dump'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install mysql_to_pg_dump
```
## TODO
 - ssh -i key.pub username@server supporting

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

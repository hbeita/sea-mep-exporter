# frozen_string_literal: true
require 'sqlite3'
class Database
  def initialize
    @db = SQLite3::Database.new 'db/sea_mep_exporter.sqlite3'
  end

  def close
    @db.close
  end

  def run(sql)
    @db.execute(sql)
  end
end
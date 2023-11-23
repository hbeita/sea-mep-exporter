# frozen_string_literal: true

require 'sqlite3'
require_relative '../db/database'
require_relative '../utils'

class SeedStudent
  include Utils
  def initialize
    @db = Database.new
  end

  def self.create_students_table
    db = Database.new
    db.run <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id TEXT PRIMARY KEY,
        full_name TEXT UNIQUE NOT NULL,
        group_id TEXT
      );
    SQL
  end

  def insert_student(id:, full_name:, group: nil)
    # trim all spaces from id
    id = id.to_s.gsub(/\s+/, '')
    # clean full_name
    normalized_full_name = normalize_string(string: full_name)
    sql = <<-SQL
      INSERT OR IGNORE INTO students (id, full_name, group_id)
      VALUES
        ('#{id}', '#{normalized_full_name}', '#{group}');
    SQL
    puts sql
    @db.run sql
    @db.close
  end
end

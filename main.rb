# frozen_string_literal: true
require_relative 'sea_mep_csv_exporter'
require_relative 'import/seed_students'
require 'csv'
require_relative 'import/students_ids'
class Main
  def self.run(self_clean: false, drop_table: false)
    # drop students table
    if drop_table
      puts 'Drop students table'
      db = Database.new
      db.run('DROP TABLE IF EXISTS students')
    end

    # create students id table
    SeedStudent.create_students_table

    # seed students id table from csv file
    puts 'Seeding students table'
    Import::StudentsIds.new(file_path: 'import/ids.xlsx').from_xls

    # check students table is not empty
    puts 'Checking students table'
    db = Database.new
    students = db.run('SELECT * FROM students')
    puts "Students table has #{students.count} rows"

    puts "create export directory"
    Dir.mkdir('export_csv') unless Dir.exist?('export_csv')

    puts 'Running SeaMepCsvExporter'
    files = Dir.glob('registros/*.xlsx')

    SeaMepCsvExporter.new(files:).run

    # zip export_csv folder and remove it
    puts 'Zipping export_csv folder'
    `zip -r export_csv.zip export_csv`
    `rm -rf export_csv` if self_clean

    puts 'Done'
  end
end

# use arguments to run the script to decide if you want to drop the table and clean the export_csv folder
self_clean = ARGV[0] == 'c' ? true : false
drop_table = ARGV[1] == 'd' ? true : false

Main.run(self_clean: , drop_table: )
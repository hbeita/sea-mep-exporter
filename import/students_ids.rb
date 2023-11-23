# frozen_string_literal: true
require_relative 'seed_students'

module Import
  class StudentsIds
    def initialize(file_path:)
      @path = file_path
    end

    def from_xls
      xls_file = SimpleXlsxReader.open(@path)

      xls_file.sheets.each do |ids_sheet|
        puts '=============================================='
        puts "#{ids_sheet.name}"
        puts '=============================================='
        ids_sheet.rows.each_with_index do |student, i|
          # puts sheet name
          id = student[0] # column A in excel is ids
          full_name = student[1] # column B in excel is full_name
          puts "   ▶︎ Insertando: [#{id}] - [#{full_name}]"
          SeedStudent.new.insert_student(id:, full_name:, group: ids_sheet.name)
        end
      end
    end
  end
end

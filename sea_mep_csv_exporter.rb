# frozen_string_literal: true

require 'simple_xlsx_reader'
require 'csv'
require_relative 'import/seed_students'
require_relative 'db/database'
require_relative 'utils'

class SeaMepCsvExporter
  include Utils
  def initialize(files: [])
    @files = files
    SeedStudent.create_students_table
    @db = Database.new
  end

  def run
    not_found_ids = []

    @files.each do |path|
      # do the name in snake case remove duplicate underscores
      registro_csv_name = path.split('/').last.split('.').first.gsub(' ', '_').downcase.gsub(/_+/, '_')

      puts "Procesando: #{registro_csv_name}"
      xls_file = SimpleXlsxReader.open(path)

      register = xls_file.sheets[0]
      # create a new csv file
      CSV.open("export_csv/#{registro_csv_name}.csv", 'wb', col_sep: ';') do |csv|
        csv << ['id', 'Nombre', 'Trabajo cotidiano', 'Tareas', 'Prueba', 'Asistencia'].map { |value| value.to_s.strip }

        name_idx = alphabet_index('C')
        cotidiano_idx = alphabet_index('D')
        tareas_idx = alphabet_index('E')
        exam_1_idx = alphabet_index('H')
        exam_2_idx = alphabet_index('K')
        exam_3_idx = alphabet_index('P')
        asistencia_idx = alphabet_index('L')

        register.rows.each_with_index do |row, _index|
          name = row[name_idx]
          id = row[alphabet_index('A')]

          next if id.nil? || id.is_a?(String) || !id.is_a?(Numeric)
          next unless id.is_a?(Numeric) || id.match?(/\A[+-]?\d+(\.\d+)?\z/)
          next if name.nil? || name.is_a?(Numeric) || name.match?(/\A[+-]?\d+(\.\d+)?\z/)

          cedula = cedula_by_name(full_name: name)
          if cedula.nil?
            not_found_ids << { name:, archivo: registro_csv_name }
            next
          end

          cotidiano = row[cotidiano_idx].nil? ? 0 : to_float(row[cotidiano_idx])
          tareas = row[tareas_idx].nil? ? 0 : to_float(row[tareas_idx])
          asistencia = row[asistencia_idx].nil? ? 0 : to_float(row[asistencia_idx])
          exam_one = row[exam_1_idx].nil? ? 0 : to_float(row[exam_1_idx])
          exam_two = row[exam_2_idx].nil? ? 0 : to_float(row[exam_2_idx])
          exam_three = row[exam_3_idx].nil? ? 0 : to_float(row[exam_3_idx])
          exam_three = 0 # NOTE: Adri changing the game!
          final_grade = (exam_one + exam_two + exam_three).round(2)

          puts "Id: #{cedula}"
          puts "Estudiante: #{name}"
          puts "Cotidiano: #{cotidiano}"
          puts "Tareas: #{tareas}"
          puts "Examenes: #{final_grade} [#{exam_one} + #{exam_two} + #{exam_three} ]"
          puts "Asistencia: #{asistencia}"
          csv << [cedula, normalize_string(string: name), cotidiano, tareas, final_grade, asistencia].map do |value|
            value.to_s.strip
          end
          puts '------------------'
        end
      end
      puts "@@@@@@@@@ End book => #{registro_csv_name}"
    end

    not_found_ids_file(not_found_ids:)
  end

  private

  def not_found_ids_file(not_found_ids: [])
    puts 'Creating not found ids file'
    CSV.open('export_csv/not_found_ids.csv', 'wb', col_sep: ';') do |csv|
      csv << %w[Nombre Archivo].map { |value| value.to_s.strip }
      not_found_ids.each do |student|
        csv << [student[:name], student[:archivo]].map { |value| value.to_s.strip }
      end
    end
  end

  def cedula_by_name(full_name:)
    normalized_full_name = normalize_string(string: full_name)
    query = <<-SQL
      SELECT id FROM students WHERE full_name LIKE '%#{normalized_full_name}%'
    SQL
    puts query
    student = @db.run query

    puts "NOT FOUND: #{full_name}" if student.empty?

    student.empty? ? nil : student.first[0]
  end

  def alphabet_index(letter)
    ('A'..'Z').to_a.index(letter)
  end

  def limit_to_two_decimals(number)
    (number * 100).round / 100.0
  end

  # TODO: CHANGE NAMING LOOKS AWFUL
  def to_float(str)
    value = str.to_f.nil? ? 0 : str.to_f
    value.is_a?(Float) ? value.round(2) : value.to_i
  end
end

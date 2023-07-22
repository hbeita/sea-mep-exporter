# frozen_string_literal: true
require 'simple_xlsx_reader'
require 'csv'

class SeaMepCsvExporter
  def initialize(files: [], clean: false)
    @files = files
    @clean = clean
  end

  def run
    # clean the export_csv folder
    if @clean
      puts 'Cleaning export_csv folder'
      FileUtils.rm_rf(Dir.glob('export_csv/*'))
    end

    @files.each do |path|
      # do the name in snake case remove duplicate underscores
      registro_csv_name = path.split('/').last.split('.').first.gsub(' ', '_').downcase.gsub(/_+/, '_')

      puts "Procesando: #{registro_csv_name}"
      xls_file = SimpleXlsxReader.open(path)

      register = xls_file.sheets[0]
      ids = xls_file.sheets[1]

      identities = ids.rows.map { |row| { id: row[1], name: row[2] } }
      # create a new csv file
      CSV.open("export_csv/#{registro_csv_name}.csv", "wb", col_sep: ';') do |csv|
        csv << ['id', 'Nombre', 'Trabajo cotidiano', 'Tareas', 'Prueba', 'Asistencia'].map { |value| value.to_s.strip }

        register.rows.each_with_index do |row, index|
          id = row[0]
          name = row[2]
          identity_found = identities.detect { |identity| identity[:name] == name }
          cedula = identity_found[:id] unless identity_found.nil?
          cotidiano = row[3].nil? ? 0 : n_to_float(row[3])
          tareas = row[4].nil? ? 0 : n_to_float(row[4])
          asistencia = row[11].nil? ? 0 : n_to_float(row[11])
          exam_one = row[7].nil? ? 0 : n_to_float(row[7])
          exam_two = row[10].nil? ? 0 : n_to_float(row[10])
          exam_three = row[17].nil? ? 0 : n_to_float(row[17])
          final_grade = (exam_one + exam_two + exam_three).round(2)

          next if id.nil? || id.is_a?(String) || !id.is_a?(Numeric)
          next unless id.is_a?(Numeric) || id.match?(/\A[+-]?\d+(\.\d+)?\z/)
          next if name.nil?

          puts "Id: #{cedula}"
          puts "Estudiante: #{name}"
          puts "Cotidiano: #{cotidiano}"
          puts "Tareas: #{tareas}"
          puts "Examenes: #{final_grade} [#{exam_one} + #{exam_two} + #{exam_three} ]"
          puts "Asistencia: #{asistencia}"
          csv << [cedula, name, cotidiano, tareas, final_grade, asistencia].map { |value| value.to_s.strip}
          puts "------------------"
        end
      end
      puts "@@@@@@@@@ End book => #{registro_csv_name}"
    end
  end

  private

  def limit_to_two_decimals(number)
    (number * 100).round / 100.0
  end

  # TODO: CHANGE NAMING LOOKS AWFUL
  def n_to_float(str)
    value = str.to_f.nil? ? 0 : str.to_f
    value.is_a?(Float) ? value.round(2) : value.to_i
  end

end


puts 'Running SeaMepCsvExporter'
files = Dir.glob('registros/*.xlsx')
clean = true

SeaMepCsvExporter.new(files:, clean: true).run

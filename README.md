# sea-mep-exporter

### Requirements
```
ruby '3.2.1'
sqlite3

Check Gemfile for more dets
```

## Steps to run the exporter
1. Do a folder inside of the repository called `registros`
2. Create an ids.xlsx file with the IDs of all the students in the college and save it in the `import` folder format expected:
```
1. Sheet per group
2. Columns
  ID, FULL_NAME

e.g: 
[7-1] sheet name
row 1 = 000000000, Chuckleberry Quackenbush Square
```
4. Run the following command `ruby main.rb`


### Additional commands
`c` after the ruby command will clean the export folder and generate a zip file with all the CSV files
`d` after the ruby command will drop the student's table and create it again on every run (useful for testing import ids)

Is extremely fast so it doesn't matter if you run it multiple times, it will just overwrite the files and generate the new db

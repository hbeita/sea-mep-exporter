# sea-mep-exporter

### Requirements
```
ruby '3.2.1'
sqlite3

Check Gemfile for more dets
```

## Steps to run the exporter
1. Do a folder inside of the repository called `registros`
2. Create a ids.xlsx file with the ids of all the students in the college and save it in the `import` folder
3. Run the following command `ruby main.rb`


### Additional commands
`c` after the ruby command will clean the export folder and just generate a zip file with the all the csv files
`d` after the ruby command will drop the students table and create it again on every run (useful for testing import ids)

Is extremely fast so it doesn't matter if you run it multiple times, it will just overwrite the files generate the new db
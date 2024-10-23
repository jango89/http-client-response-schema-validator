#!/usr/bin/env bash

#USAGE -> "validate-schema.sh 'collection/{collection_name}/schemas'"

# Check the first argument(filepath) to this function exists.
check_directory_exists () {
  #Check if schema directory exists and skip validation if not present.
    if [ "$(ls -1 "$1" | wc -l)" -eq 0 ]
      then
        echo "No schema files found in path: $1"
        exit 0
    fi;
}

check_first_argument_is_present() {
  if [ $1 -eq 0 ]
    then
      echo "No arguments supplied, please provide path of schema 'collection/{collection_name}/schemas'";
      exit 1
  fi
}

check_first_argument_is_present $#

mkdir -p target
mkdir -p reports

#Report name should start with `report`, since its used for attaching in emails(Jenkinsfile)
report_schema_errors_file_name="report-schema-errors.txt"

temp_validation_result_file_name="validation_result.txt"

schema_errors_path="$(pwd)/reports/$report_schema_errors_file_name"
temp_validation_result_file_name="$(pwd)/target/$temp_validation_result_file_name"

#Clean up if files exists
rm -r -f "$schema_errors_path"


current_working_directory="${PWD%/}/$1"

#Check if schema directory exists and skip validation if not present.
check_directory_exists "$current_working_directory"

cd "$current_working_directory"

#Check if schema directory exists and skip validation if not present.
check_directory_exists "."

#Looping through each schema directory
for directory in */* ; do

  #Check if schema directory exists and skip validation if not present.
  check_directory_exists "$directory"

  number_of_schema_files_in_directory=$(ls -1 "$directory" | grep -c "schema")
  number_of_generated_files_in_directory=$(ls -1 "$directory" | grep -c "generated")

  # Atleast 1 schema file and 1 generated-response file should be present
  if [ "$number_of_schema_files_in_directory" -eq 1 ] && [ "$number_of_generated_files_in_directory" -ge 1 ]
    then

      # DEBUGGING ECHO
#      echo "Validating schema in: ${directory}"

      # Validation command executed
      cd "$directory" && ajv validate -s "schema.json" -d "generated*.json" --errors=text > "$temp_validation_result_file_name" 2>&1

      # Store the exit code for the validation command
      exit_code_from_validate_command=$(echo $?)

      # If errors are present, save it to the error file
      if [ "$exit_code_from_validate_command" -gt 0 ]
        then
          echo "$directory:" >> "$schema_errors_path"
          cat "$temp_validation_result_file_name" >> "$schema_errors_path"
          echo "" >> "$schema_errors_path"
      fi;
  else
    (echo "$directory"; echo "Schema files = ${number_of_schema_files_in_directory}, Generated files = ${number_of_generated_files_in_directory}, "; echo "Max 1 schema file and at-least 1 generated file should be present for schema validation"; echo "")  >> "$schema_errors_path"
  fi;

  cd "$current_working_directory"

done;

#Clean up temp file
rm -r -f "$temp_validation_result_file_name"

#If there are error codes greater than zero, there are errors
if [ -f "$schema_errors_path" ]
  then
    echo ""
    echo "Below errors found during schema validation"
    echo "-------------------------------------------"
    cat "$schema_errors_path"
    exit 1
  else
    echo ""
    echo "No errors found during schema validation"
    exit 0
fi

### Response Schema Validation

The shell script should help to validate JSON Responses stored in each folder againsts corresponding "schema.json" (JSON Schema file).
This logic can be used in QA Automation test suites run using Intellij Http Client since there is no default Schema Validation support in the client.

#### How is it done
However, we use an external tool called `ajv-cli` to perform validation. 
1. Create directories in this format `collections/{collection_name}/schemas/{api-step-name}/{response-status-code}`.
2. Place json schema for respective response status in a file called `schema.json`.
3. Inside the `API` definition for the same step store response to a file called generated.json using this code `>>! ../schemas/[STEP 2.01].create-sales-record/200/generated*{anyname}.json`
4. Later with the help of a tool, we will validate the file called `schema.json` against all generated responses of format `generated*.json`.

#### Validation of response schemas locally. 
1. Run this command `npm install -g ajv-cli` to install the tool.
2. Run this command `./validate-schema.sh "collection/{collection-name}/schemas/"` to validate schemas inside a collection.

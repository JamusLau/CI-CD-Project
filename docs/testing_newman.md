# Newman
CLI Version of Postman

Install Newman globally using: `npm install -g newman`

To run tests using Newman:
```sh
newman run path/to/collection.json -e path/to/environment.json --reporters cli, junit --reporter-junit-export ./output/results.xml
```
- `-e` specifies the environment file loaction.
- `--reporters` specifies which reporters to use.
- `--reporter-junit-export` exports the report in the Junit format
Note: not all options have to be used.

### collection.json
A `Collection` is a group of API requests that you defined in Poastman. It can include HTTP methods like GET, POST, PUT, DELETE, headers, body data etc, and any neccessary configurations required for each request. Allows you to run related API tests together.

The collection.json file can be created from scratch or can be exported from the Postman application. \
An example of a collection.json file:
```json

```

### environment.json
An `Environment` is a set of key-value pairs that store variables used in API requests, allowing you to easily switch between contexts without changing the requests manually. It allows you to define variables such as base URLs, authentication tokens, or dynamic data.

The environment.json file can be created from scratch or can be exported from the Postman application. \
An example of a environment.json file:
```json

```
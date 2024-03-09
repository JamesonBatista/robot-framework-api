# 🤖 Robot Framework 🤖 
##  Requests using JSONs

<br>
<br>

## 🤖 Clone repository


```bash
# Clone repository
$ git clone <https://github.com/JamesonBatista/robot-framework-api.git>

$ cd tests

$ robot .

```
----
## 🤖 Using:
<br>

### 🤖 Paths use in JSON

-  _status_
- _method_
- _url_
- _body_
- _replace_
- _expect_
- _save_
- _path_
----
### 🤖 Environment use:

```json
{
	"env": "QA",
	"QA": {
	  "users": "https://reqres.in/api/users/2",
	  "restcountries": "https://restcountries.com/v3.1/translation/germany",
	  "users_base":"https://reqres.in/api/users",
	  "serverest":"https://serverest.dev",
	  "booking": "https://restful-booker.herokuapp.com/booking"
	},
	"DEV": {
	  "users": "http://example.com/dev/users"
	},
	"PROD": {
	  "users": "http://example.com/prod/users"
	}
  }
```
----
## 🤖 Examples use:

```json
{
  "status": 200, // use status
  "url": "serverest/login", // get environment in env.json
  "body": {
    "email": "fulano@qa.com",
    "password": "teste"
  },
  "save":[{"path": "authorization", "as": "token"}] // save value for path, use **as** rename value name save, or the keyword will use the name described in the path
}

```
## OR
```json
{
  "status": 200, // use status
  "method": "POST",
  "url": "serverest/login", // get environment in env.json
  "path": "user", // path will look for the variable named "user" and use it in the url along with what is present "url": "serverest/login/value path"
  "body": {
    "email": "fulano@qa.com",
    "password": "teste"
  },
  "save":[{"path": "authorization", "as": "token"}] // save value for path, use as rename value name save
}
```

---

> ### Obs: *Requests where the JSON address is passed as a string do not need a user method within the JSON, just put get_, post_ at the beginning of the file name.*
<br>

```py

*** Settings ***
Resource    ../Resources/resources_keywords.robot
Library    FakerLibrary    locale=pt_BR

*** Test Cases ***
Test init
    ${response}    Request    ../jsons/post_token

```
---
## 🤖 Examples use whit expect:

```json
{
  "status": 200,
  "url": "serverest/login",
  "body": {
    "email": "fulano@qa.com",
    "password": "teste"
  },
  "save":[{"path": "authorization", "as": "token"}],
  "expect": [{"path": "name", "eq": "Jam"}] // expect find in JSON 
}

```
---
## 🤖 Examples use whit expect whit save:

```json
{
  "status": 200,
  "url": "serverest/login",
  "body": {
    "email": "fulano@qa.com",
    "password": "teste"
  },
  "save":[{"path": "authorization", "as": "token"}],
  "expect": [{"path": "name", "eq": "Jam", "save": true}] // save whit name path, ex: "name"
}
```
---
## 🤖 Examples use whit replace:
```json
{
	"status": 201,
	"url": "serverest/usuarios",
	"replace": "faker_name, faker_email, token", // replace use data save in request or in test
	"headers":{
		"Authorization": "token"
	},
	"body":{
		"nome": "faker_name",
		"email": "faker_email",
		"password": "teste",
		"administrador": "true"
	  }
}
```
## 🤖 Example save data for use in replace

```py
Test - Generate new user

    ${name}    FakerLibrary.Name
    Save    faker_name    ${name}
    ${email}    FakerLibrary.Email
    Save    faker_email    ${email}
```

---
## 🤖 Snippets
<br>

 > *Construct requisition*
 -  ### _.req_ 

```py
Test - Construct request
		${response}    Request    ../jsons/get    True
```
---

 > *Get value variable that was saved*
 - ### _.variable_ 
 ```py
	Save    faker_name    ${name}
 	${rescue_value}=    GET_VARIABLE_GLOBAL    faker_name
 ```
 ---

 > *Chance values in JSON for use in request, in JSON necessary use method: "GET", "POST"...*
 -  ### _.json_	
 ```py
     ${json}=    JSON_CHANGE    ../jsons/post    body    {'name': 'faker_name'}
     ${response}    Request    ${json}    True
 ```
---

> *For validate status code outside JSON*
  - ### _.status_
```py
	${response}    Request    ${json}    True
	STATUS_CODE    ${response}    status    200
```
---

> *Create a complete request*
- ### _.test_

```py
*** Settings ***
Resource    ../Resources/resources_keywords.robot
Library    FakerLibrary    locale=pt_BR
*** Variables ***

*** Test Cases ***
Test init
    ${response}    Request    ../jsons/get    True

```
---

> *Save data for using in change JSON or replace*
- ### _.save_

```py
Test - Using save

    ${name}    FakerLibrary.Name
    Save    faker_name    ${name}
    ${email}    FakerLibrary.Email
    Save    faker_email    ${email}
```
---


## _Author_

 <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/45885028?s=400&u=7fedc35e176bfbb56e66ee218fb7ce4075cfa1ea&v=4" width="100px;" alt=""/>
 <br />
 <sub><b>Jam Batista</b></sub></a> 


Feito com ❤️ por Jam Batista 👋🏽 Entre em contato!

[![Linkedin Badge](https://img.shields.io/badge/-JamBatista-blue?style=flat-square&logo=Linkedin&logoColor=white&link=https://www.linkedin.com/in/tgmarinho/)](https://www.linkedin.com/in/jam-batista-98101015b/) 

---
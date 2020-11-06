# wanderlust-server
Django back end for our team project.

## Requirements
- `pipenv`. If you dont have it either `pip install pipenv` on windows or `pip3 install pipenv` on mac/linux.

## Installation
To install the server
1. Clone the repository: `git clone https://github.com/Deco3801-Team-Nintendogs/wanderlust-server.git server`
2. `cd server`
3. Setup and enter the virtual environment: `pipenv install && pipenv shell`
4. Start the django server: `python3 manage.py runserver`. On windows replace `python3` with `python` or `py`

The server should now be available at localhost:8000


## DB Migrations
Whenever you make changes to the models and you want these to propagate across the database these are the commands you'll need to run.
1. `python3 manage.py makemigrations && python3 manage.py migrate`


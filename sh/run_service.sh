#!/usr/bin/env bash
source virtual_env/bin/activate
cd webkeeper/
python manage.py runserver 0.0.0.0:9300

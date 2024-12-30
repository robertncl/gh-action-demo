install:
	pip install --upgrade pip && python -m venv myvenv && . myvenv/bin/activate && pip install -r requirements.txt

lint:
	pylint --disable=R,C hello.py

format:
	black *.py

test:
	python -m pytest -vv --cov=hello test_hello.py

all: install lint test
IMAGE ?= local/insight-agent:dev

.PHONY: test build run
test:
	python -m pip install -r app/requirements.txt pytest ruff
	ruff check .
	pytest -q

build:
	docker build -t $(IMAGE) .

run:
	docker run --rm -p 8080:8080 $(IMAGE)
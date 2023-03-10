subdir = $(shell ls -l | grep ^d | awk '{print $$9}')

.PHONY: build all test

all: build

build:
	go build -ldflags "-s -w" -o lotus-car ./*.go

test:
	bundle2.7 exec rspec -f d

clean:
	rm -rfv ./lotus-car
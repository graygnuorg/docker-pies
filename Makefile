VERSION=1.5.90
OSVERSION=10

all: .pies-$(VERSION).ts	

.pies-%.ts: Dockerfile
	docker build -t graygnuorg/pies-debian:$* $(CACHE) --build-arg OSVERSION=$(OSVERSION) .
	touch $@

VERSION=1.5.94
OSVERSION=10

all: .pies-$(VERSION).ts	

.pies-%.ts: Dockerfile
	docker build -t graygnuorg/pies:$* $(CACHE) --build-arg OSVERSION=$(OSVERSION) .
	touch $@

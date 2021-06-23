USER=graygnuorg
IMAGE=pies
PLATFORM=debian
BUILD=2.0
OSVERSION=10

ifneq (,$(wildcard config.mk))
  include config.mk
endif

IMAGENAME = $(USER)/$(IMAGE):$(PLATFORM)-$(BUILD)

all: .$(IMAGE)-$(BUILD).ts

.$(IMAGE)-$(BUILD).ts: Dockerfile
	docker build -t $(IMAGENAME) $(CACHE) \
                --build-arg OSVERSION=$(OSVERSION) \
                --build-arg PIES_TAG=$(PIES_TAG) \
                --build-arg XENV_TAG=$(XENV_TAG) \
                .
	touch $@

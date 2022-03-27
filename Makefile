.PHONY: mirrors

TARGET = all

WORKDIR           = /build
MAKEFILE_PWD      = $(realpath $(dir $(abspath $(firstword $(MAKEFILE_LIST)))))
MIRRORS_ROOT      = "$(MAKEFILE_PWD)/mirrors"
DEBMIRROR_DEFAULT = "$(MAKEFILE_PWD)/conf/debmirror/_default.conf"

mirrors:
	docker run --env TARGET='$(TARGET)' \
                   --mount type=bind,source=$(MAKEFILE_PWD),target=$(WORKDIR) \
                   --mount type=bind,source=$(MIRRORS_ROOT),target=$(WORKDIR)/mirrors \
                   --mount type=bind,source=$(DEBMIRROR_DEFAULT),target=/etc/debmirror.conf,readonly \
                   --user $(shell id -u "${USER}"):$(shell id -g "${USER}") \
                   --rm \
                   penguinspiral/seed-mirrors:bullseye-slim

clean:
	rm --force --verbose $(MAKEFILE_PWD)/seed-mirrors*.log

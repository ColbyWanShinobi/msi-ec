-include ../../Makefile.vars
-include Makefile.vars

PROJECT_DIR := $(abspath ../..)
RPM_ROOT   ?= $(PROJECT_DIR)/dist/rpmbuild
DIST_DIR   := $(MODNAME)-$(VERSION)

# Increment when the packaging changes without an upstream driver version
# change, so consumers can request the corrected RPM artifact explicitly.
RELEASE    ?= 2
DATE_RPM   := $(shell date -u +"%a %b %d %Y")

.PHONY: srpm clean dist rpm

clean:
	rm -rf $(RPM_ROOT) $(DIST_DIR).tar.gz

dist: clean
	mkdir -p $(DIST_DIR)
	cp ../../{*.c,*.h,Makefile,Makefile.vars,LICENSE} $(DIST_DIR)/
	tar -czf $(DIST_DIR).tar.gz $(DIST_DIR)
	rm -rf $(DIST_DIR)

srpm: dist
	mkdir -p $(RPM_ROOT)/{SOURCES,SPECS,SRPMS}
	mv $(DIST_DIR).tar.gz $(RPM_ROOT)/SOURCES/
	
	echo "$(MODNAME)" > $(RPM_ROOT)/SOURCES/module-load.conf
	
	cp depmod-override.conf $(RPM_ROOT)/SOURCES/ ; \
	
	sed -e "s|@MODNAME@|$(MODNAME)|g" \
	    -e "s|@VERSION@|$(VERSION)|g" \
		-e "s|@RELEASE@|$(RELEASE)|g" \
	    akmod.spec.in > $(RPM_ROOT)/SPECS/$(MODNAME)-kmod.spec
	printf '* %s msi-ec package maintainers <noreply@github.com> - %s-%s\n- Build the akmod RPM.\n' "$(DATE_RPM)" "$(VERSION)" "$(RELEASE)" >> $(RPM_ROOT)/SPECS/$(MODNAME)-kmod.spec

	rpmbuild --define "_topdir $(RPM_ROOT)" -bs $(RPM_ROOT)/SPECS/$(MODNAME)-kmod.spec
	@if [ -n "$(outdir)" ]; then cp $(RPM_ROOT)/SRPMS/*.src.rpm $(outdir)/; fi

rpm: srpm
	set -- $(RPM_ROOT)/SRPMS/$(MODNAME)-kmod-$(VERSION)-$(RELEASE)*.src.rpm; \
	test -f "$$1"; \
	rpmbuild --define "_topdir $(RPM_ROOT)" --rebuild "$$1"

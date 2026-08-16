include ../../Makefile.vars

export MODNAME
export VERSION

DATE_SLUG := $(shell date +%Y%m%d%H%M)

GIT_SLUG=$(shell git rev-parse --short HEAD)
export RELEASE := $(DATE_SLUG)git$(GIT_SLUG)

.PHONY: package-all deb clean-pkg

package-all: prepare-build deb

prepare-build:
	@sed -e "s|@MODNAME@|$(MODNAME)|g" \
	     -e "s|@VERSION@|$(VERSION)|g" \
	     -e "s|@RELEASE@|$(RELEASE)|g" \
	     -e "s|@VERSION_FULL@|$(FULL_VERSION)|g" \
	     scripts/postinstall.sh.in > scripts/postinstall.sh
	
	@sed -e "s|@MODNAME@|$(MODNAME)|g" \
	     -e "s|@VERSION@|$(VERSION)|g" \
	     -e "s|@RELEASE@|$(RELEASE)|g" \
	     -e "s|@VERSION_FULL@|$(FULL_VERSION)|g" \
	     scripts/preremove.sh.in > scripts/preremove.sh
	
	@chmod +x scripts/postinstall.sh scripts/preremove.sh

deb:
	@echo "📦 Building Debian package v$(VERSION)-$(RELEASE)..."
	nfpm pkg --target $(MODNAME)-dkms_$(VERSION)-$(RELEASE).deb

clean-pkg:
	@echo "🧹 Cleaning packages..."
	rm -f *.deb scripts/postinstall.sh scripts/preremove.sh

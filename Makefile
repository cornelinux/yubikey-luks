DEB_FILES=debian/changelog debian/compat debian/control debian/copyright debian/fido2-luks.postinst debian/rules debian/source
SRC_FILES=fido2-luks-enroll fido2-luks-enroll.1 fido2-luks-open fido2-luks-open.1 fido2-luks.cfg fido2-utils.sh hook key-script Makefile README.md

info:
	@echo "builddeb [NO_SIGN=1]  - build deb package for Ubuntu LTS [NO_SIGN disables signing]"
	@echo "clean                 - clean build directory DEBUILD"
	@echo "ppa-dev               - upload to ppa launchpad. Development"
	@echo "ppa                   - upload to ppa launchpad. Stable"

VERSION=0.1.0
PACKAGE=fido2-luks
SRC_DIR=${PACKAGE}-${VERSION}

debianize: ${SRC_FILES} ${DEB_FILES}
	rm -fr DEBUILD
	mkdir -p DEBUILD/${SRC_DIR}/debian
	cp ${SRC_FILES} DEBUILD/${SRC_DIR}
	cp -r ${DEB_FILES} DEBUILD/${SRC_DIR}/debian/
	(cd DEBUILD; tar -zcf fido2-luks_${VERSION}.orig.tar.gz --exclude=${SRC_DIR}/debian  ${SRC_DIR})

builddeb: ${SRC_FILES} ${DEB_FILES}
	make debianize
ifndef NO_SIGN
	(cd DEBUILD/${SRC_DIR}; debuild)
else
	(cd DEBUILD/${SRC_DIR}; debuild -uc -us)
endif

ppa-dev:
	make debianize
	(cd DEBUILD/${SRC_DIR}; debuild -S)
	# Upload to launchpad:
	dput ppa:privacyidea/privacyidea-dev DEBUILD/fido2-luks_${VERSION}-?_source.changes

ppa:
	make debianize
	(cd DEBUILD/${SRC_DIR}; debuild -S)
	# Upload to launchpad:
	dput ppa:privacyidea/privacyidea DEBUILD/fido2-luks_${VERSION}-?_source.changes

clean:
	rm -fr DEBUILD

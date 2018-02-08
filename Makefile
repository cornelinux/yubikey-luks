info:
	@echo "builddeb        - building debian package for Ubuntu LTS"
	@echo "builddeb-nosign - building debian package for Ubuntu LTS WITHOUT SIGNING"
	@echo "ppa-dev         - upload to ppa launchpad. Development"
	@echo "ppa	       - upload to ppa launchpad. Stable"

VERSION=0.5.1
SRC_DIR = yubikey_luks.orig

debianize:
	rm -fr DEBUILD
	mkdir -p DEBUILD/${SRC_DIR}
	cp -r * DEBUILD/${SRC_DIR} || true
	(cd DEBUILD; tar -zcf yubikey-luks_${VERSION}.orig.tar.gz --exclude=${SRC_DIR}/debian  ${SRC_DIR})

builddeb:
	make debianize
	(cd DEBUILD/${SRC_DIR}; debuild)

builddeb-nosign:
	make debianize
	(cd DEBUILD/${SRC_DIR}; debuild -uc -us)

ppa-dev:
	make debianize
	(cd DEBUILD/${SRC_DIR}; debuild -S)
	# Upload to launchpad:
	dput ppa:privacyidea/privacyidea-dev DEBUILD/yubikey-luks_${VERSION}-?_source.changes

ppa:
	make debianize
	(cd DEBUILD/${SRC_DIR}; debuild -S)
	# Upload to launchpad:
	dput ppa:privacyidea/privacyidea DEBUILD/yubikey-luks_${VERSION}-?_source.changes



TARGET=build
SVCNAME=portmosq
DEBSDIR=debs

all: ${SVCNAME}.raw

# Build a a squashfs file system from the static service binary, the
# two unit files and the os-release file (together with some auxiliary
# empty directories and files that can be over-mounted from the host.
${SVCNAME}.raw: install ${SVCNAME}.service os-release
	mkdir -p ${TARGET}/usr/bin ${TARGET}/usr/lib/systemd/system ${TARGET}/etc ${TARGET}/proc ${TARGET}/sys ${TARGET}/dev ${TARGET}/run ${TARGET}/tmp ${TARGET}/var/tmp ${TARGET}/var/lib/mosquitto
	cp ${SVCNAME}.service ${TARGET}/usr/lib/systemd/system
	cp os-release ${TARGET}/usr/lib/os-release
	touch ${TARGET}/etc/resolv.conf ${TARGET}/etc/machine-id
	cp mosquitto.conf ${TARGET}/etc/mosquitto/
	rm -f ${SVCNAME}.raw
	mksquashfs ${TARGET}/ ${SVCNAME}.raw -noappend -comp xz

install:
	mkdir -p ${DEBSDIR}
	cd ${DEBSDIR} && \
	apt-get download libc6 libwrap0 libsystemd0 libdlt2 libssl3 libwebsockets16 \
	  libnsl2 liblzma5 libzstd1 liblz4-1 libcap2 libgcrypt20 libev4 libuv1 \
	  zlib1g libtirpc3 libgssapi-krb5-2 libkrb5-3 libkrb5support0 libkeyutils1 \
	  libgpg-error0 libk5crypto3 libcom-err2 mosquitto && \
	cd ..
	find debs -type f -exec echo Extracting {} \; -exec dpkg -x {} ${TARGET} \;

clean:
	rm -rf debs
	rm -rf ${TARGET}
	rm -f ${SVCNAME}.raw

.PHONY: all install clean

#!/bin/bash -e

time=$(date +%Y-%m-%d)
DIR="$PWD"

./RootStock-NG.sh -c scypho-base.conf 
#./RootStock-NG.sh -c scypho-base-3.17.conf 

scypho_base="scypho-base-${time}"
archive="xz -z -8 -v"

cat > ${DIR}/deploy/gift_wrap_final_images.sh <<-__EOF__
#!/bin/bash

pre_generic_img () {
        if [ -d ./\${base_rootfs} ] ; then
                rm -rf \${base_rootfs} || true
        fi

        if [ -f \${base_rootfs}.tar.xz ] ; then
                tar xf \${base_rootfs}.tar.xz
        else
                tar xf \${base_rootfs}.tar
        fi
}

generic_img () {
        cd \${base_rootfs}/
        sudo ./setup_sdcard.sh \${options}
        mv *.img ../
        cd ..
}

post_generic_img () {
        if [ -d ./\${base_rootfs} ] ; then
                rm -rf \${base_rootfs} || true
        fi

        if [ ! -f \${base_rootfs}.tar.xz ] ; then
                ${archive} \${base_rootfs}.tar
        fi
}

compress_img () {
        if [ -f \${wfile} ] ; then
                ${archive} \${wfile}
        fi
}

### Producing Scypho Image
#Scypho
base_rootfs="${scypho_base}"
pre_generic_img

options="--img-4gb BBB-eMMC-flasher-${scypho_base}       --dtb beaglebone       --beagleboard.org-production --boot_label SCYPHOCU --enable-systemd --rootfs_label eMMC-Flasher --bbb-flasher"
generic_img

###archive *.tar
base_rootfs="${scypho_base}"
post_generic_img

###archive *.img
wfile="BBB-blank-eMMC-flasher-${scypho_base}-4gb.img"
compress_img

__EOF__

chmod +x ${DIR}/deploy/gift_wrap_final_images.sh

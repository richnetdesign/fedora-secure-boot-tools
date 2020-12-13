#!/bin/bash

K_VERSION=$(uname -r)

if ! [ -x "$(command -v fzf)" ]; then
  echo 'Error: fzf is not installed.' >&2
  exit 1
fi

K_VERSION="$(ls -1 /usr/src/kernels/ | fzf -1 --prompt "Select kernel version to sign: " )"

KSOURCE_PATH="/usr/src/kernels/$K_VERSION/scripts/:$PATH"

#Append kernel scripts to path to help sign modules
PATH="$KSOURCE_PATH:$PATH"

#Choose modules that need signing
NVIDIA_MODULES="nvidia nvidia-drm nvidia-modeset nvidia-uvm"
ZFS_MODULES="spl wireguard zavl zcommon zfs zlua znvpair zunicode zzstd zstd icp"
OTHER_MODULES=""

ALL_MODULES="$NVIDIA_MODULES $ZFS_MODULES $OTHER_MODULES"

KEY_DIR="./"

MOK_KEY="$KEY_DIR/MOK.priv"
MOK_X509="$KEY_DIR/MOK.der"

SHA_FORMAT="sha256"

#loop over all modules, decompress, sign and recompress
for module in $ALL_MODULES
do

    modulepath=$(modinfo -n $module -k $K_VERSION )
    module_basename=${modulepath:0:-3}
    module_suffix=${modulepath: -3}

    #echo $module_basename

    if [[ "$module_suffix" == ".xz" ]]; then
        
        unxz $modulepath
        echo sign-file sha256 "${MOK_KEY}" "${MOK_X509}" "${module_basename}"
        sign-file $SHA_FORMAT  "${MOK_KEY}" "${MOK_X509}" "${module_basename}"
        xz -f ${module_basename}

    elif [[ "$module_suffix" == ".gz" ]]; then
        
        gunzip $modulepath
        sign-file $SHA_FORMAT "${key}" "${x509}" "${module_basename}"
        gzip -9f $module_basename

    else
        sign-file $SHA_FORMAT "${MOK_KEY}" "${MOK_X509}" "${modulepath}"
    fi

    MODPATH=$(modinfo -n $module )

done

exit 0

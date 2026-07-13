#!/bin/bash
#
# applyPatches.sh — KernelSU-Next integration with Manual Hooks for Revive-Selene

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

echo ">>> Initializing KernelSU-Next submodule..."
git submodule update --init --recursive

if [ ! -d "${maindir}/KernelSU-Next/kernel" ]; then
  echo "ERROR: KernelSU-Next/kernel not found after submodule init."
  echo "Make sure your kernel branch has .gitmodules and the KernelSU-Next submodule."
  exit 1
fi

if [ ! -L "${maindir}/drivers/kernelsu" ]; then
  echo "WARNING: drivers/kernelsu symlink missing, creating..."
  ln -sf ../KernelSU-Next/kernel "${maindir}/drivers/kernelsu"
fi

KSU_hashcommit=$(cd "${maindir}/KernelSU-Next" && git rev-parse --short=7 HEAD)
echo ">>> KernelSU-Next commit: ${KSU_hashcommit}"

# === PERUBAHAN PENTING: APPLY MANUAL HOOKS PATCHES ===
echo ">>> Applying KernelSU Manual Hooks Patches for kernel 4.14..."

PATCH_DIR="${outside}/ksu/patches/4.14"

# Mengecek apakah folder patch ada
if [ -d "$PATCH_DIR" ]; then
  # Mencari semua file berakhiran .patch dan mengurutkannya
  for patch_file in $(ls "$PATCH_DIR"/*.patch | sort); do
    echo " -> Applying patch: $(basename "$patch_file")"
    
    # Perintah sakti untuk menempelkan patch ke kernel (mengabaikan jika sudah pernah dipatch)
    patch -p1 -N -i "$patch_file" -r -
    
    if [ $? -eq 0 ]; then
      echo "    [SUCCESS] Patch applied."
    else
      echo "    [WARNING] Patch failed or already applied."
    fi
  done
else
  echo "ERROR: Patch directory not found at $PATCH_DIR"
  echo "Manual hooks will not be integrated, build will likely fail!"
fi
# =======================================================

# Membiarkan CONFIG_LOCALVERSION apa adanya
orig_localversion=$(grep 'CONFIG_LOCALVERSION=' "${defconfig_file}" 2>/dev/null | sed 's/CONFIG_LOCALVERSION=//g' | sed 's/"//g')
echo ">>> Retaining original localversion: ${orig_localversion}"

echo -e " \nincludes KernelSU-Next (KernelSU), commit ${KSU_hashcommit}" >> banner_append

echo ">>> KernelSU-Next submodule ready. Manual hooks integrated."

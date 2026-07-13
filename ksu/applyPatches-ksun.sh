#!/bin/bash
#
# applyPatches.sh — ReSukiSU integration for Revive-Selene
#
# This script assumes the kernel source was cloned from a branch
# that already has ReSukiSU manual hooks integrated (e.g. Hydrogen).
# The KernelSU/ folder is a git submodule pointing to ReSukiSU/ReSukiSU.
# This script simply initializes the submodule so the driver source is present.

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

# === PERUBAHAN DI SINI ===
# Kita membiarkan CONFIG_LOCALVERSION apa adanya (sesuai settingan asli di defconfig)
# dan HANYA mencatat info KSU di dalam file banner_append (untuk log/catatan rilis).

orig_localversion=$(grep 'CONFIG_LOCALVERSION=' "${defconfig_file}" 2>/dev/null | sed 's/CONFIG_LOCALVERSION=//g' | sed 's/"//g')
echo ">>> Retaining original localversion: ${orig_localversion}"

echo -e " \nincludes KernelSU-Next (KernelSU), commit ${KSU_hashcommit}" >> banner_append

echo ">>> KernelSU-Next submodule ready. Kernel name remains unchanged."

#!/bin/bash

# Extraer el VG usado en GRUB
VG_IN_GRUB=$(grep ^GRUB_CMDLINE_LINUX= /etc/default/grub | grep -oP 'rd.lvm.lv=\K[^/]+')

if [ -z "$VG_IN_GRUB" ]; then
  echo "⚠️ No se encontró un valor 'rd.lvm.lv=' en /etc/default/grub"
  exit 1
fi

# Obtener los VGs reales del sistema
VG_EXISTENTES=$(vgs --noheadings -o vg_name | awk '{$1=$1};1')

# Comparar
if echo "$VG_EXISTENTES" | grep -qw "$VG_IN_GRUB"; then
  echo "✅ El VG usado en GRUB ($VG_IN_GRUB) existe en el sistema."
else
  echo "❌ El VG usado en GRUB ($VG_IN_GRUB) NO coincide con los VGs actuales:"
  echo "$VG_EXISTENTES"
  echo
  echo "Por favor, actualiza /etc/default/grub con el VG correcto y regenera el grub."
  exit 2
fi

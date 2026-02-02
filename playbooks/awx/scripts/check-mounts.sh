#!/bin/bash
# Uso: ./check-mount.sh

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

problemas=0
total_verificados=0
declare -a montajes_problematicos

verificar_fstab() {
  local dispositivo=$1
  local punto_montaje=$2

  if [[ $dispositivo == /dev/* ]]; then
    uuid=$(blkid -s UUID -o value "$dispositivo" 2>/dev/null)
    if [ -n "$uuid" ] && grep -qE "^\s*UUID=$uuid\s+" /etc/fstab; then
      return 0
    fi
  fi

  grep -qE "^\s*$dispositivo\s+" /etc/fstab && return 0
  grep -qE "^\s*\S+\s+$punto_montaje\s+" /etc/fstab && return 0

  return 1
}

verificar_systemd() {
  local punto_montaje=$1
  unit_name=$(systemd-escape -p --suffix=mount "$punto_montaje")

  if systemctl is-enabled "$unit_name" &>/dev/null; then
    return 0
  fi

  find /etc/systemd/system /usr/lib/systemd/system -name "*.mount" -type f 2>/dev/null \
    | xargs grep -l "Where=$punto_montaje" 2>/dev/null | grep -q . && return 0

  return 1
}

verificar_initd() {
  local punto_montaje=$1
  local dispositivo=$2

  [ -d /etc/init.d ] || return 1
  grep -rl "$punto_montaje" /etc/init.d/* &>/dev/null && return 0
  grep -rl "$dispositivo" /etc/init.d/* &>/dev/null && return 0

  return 1
}

verificar_rclocal() {
  local punto_montaje=$1
  local dispositivo=$2

  local rc="/etc/rc.local"
  [ -f /etc/rc.d/rc.local ] && rc="/etc/rc.d/rc.local"
  [ -f "$rc" ] || return 1

  grep -q "$punto_montaje" "$rc" && return 0
  grep -q "$dispositivo" "$rc" && return 0

  return 1
}

echo "=========================================="
echo "Verificación de Montajes Persistentes"
echo "=========================================="
echo ""

montajes=$(mount | grep -v -E "^(sysfs|proc|devpts|cgroup2?|pstore|bpf|configfs|selinuxfs|debugfs|tracefs|fusectl|securityfs|efivarfs|autofs|mqueue|hugetlbfs)" \
  | grep -v "/sys/kernel/" | awk '{print $1 "|" $3}')

#echo -e "${BLUE}Montajes a verificar:${NC}"
#echo "$montajes" | while IFS='|' read -r d m; do
#  echo " - $m ($d)"
#done
#echo ""

while IFS='|' read -r dispositivo punto_montaje; do
  [[ -z "$dispositivo" || -z "$punto_montaje" ]] && continue
  [[ "$punto_montaje" == "/" ]] && continue
  [[ "$punto_montaje" =~ ^/run(/|$) ]] && continue
  [[ "$punto_montaje" == "/dev" ]] && continue
  [[ "$punto_montaje" == "/dev/shm" ]] && continue
  [[ "$punto_montaje" == "/sys/fs/cgroup" ]] && continue

  ((total_verificados++))

  encontrado=false

  verificar_fstab "$dispositivo" "$punto_montaje" && encontrado=true
  verificar_systemd "$punto_montaje" "$dispositivo" && encontrado=true
  verificar_initd "$punto_montaje" "$dispositivo" && encontrado=true
  verificar_rclocal "$punto_montaje" "$dispositivo" && encontrado=true

  if [ "$encontrado" != true ]; then
    ((problemas++))
    montajes_problematicos+=("$punto_montaje")
  fi
done <<< "$montajes"

# ==== SALIDA PARA ANSIBLE (stderr SOLO SI HAY ERRORES) ====
#if [ "$problemas" -ne 0 ]; then
#  {
#    echo "=========================================="
#    echo "RESUMEN"
#    echo "=========================================="
#    echo "Total de montajes verificados: $total_verificados"
#    echo "✗ Se encontraron $problemas montaje(s) sin configuración persistente:"
#    for m in "${montajes_problematicos[@]}"; do
#      echo " - $m"
#    done
#  }
#  exit 1
#fi

# ==== SALIDA PARA ANSIBLE (solo los errores, minimalista) ====
if [ "$problemas" -ne 0 ]; then
  echo "ERROR: Se encontraron $problemas montaje(s) sin configuración persistente (total verificados: $total_verificados):"
  for m in "${montajes_problematicos[@]}"; do
    echo " - $m"
  done
  exit 1
fi

echo -e "${GREEN}✓ Todos los montajes están configurados correctamente${NC}"
exit 0

#!/bin/bash

# Leer servidores de origen (desde donde se hacen las pruebas)
mapfile -t servers < srv-origen.txt

# Leer destinos y convertirlos en una cadena separada por espacios
srv_destinos=$(<srv-destino.txt)

# Leer puertos y convertirlos en una cadena separada por espacios
srv_ports=$(<srv-destino-port.txt)

# Cabecera tabla
printf "%-15s %-30s %-6s %-12s\n" "ServidorOrigen" "ServidorDestino" "Puerto" "Estado"
printf "%-15s %-30s %-6s %-12s\n" "--------------" "------------------------------" "------" "------------"

for server in "${servers[@]}"; do

  # Verifica si se puede conectar al servidor SSH
  if ssh -q -o ConnectTimeout=5 "$server" "exit" 2>/dev/null; then

    # Ejecuta remotamente y expande srv_destinos dentro del heredoc
    ssh -q "$server" /bin/bash <<ENDSSH
    hosts=($srv_destinos)
    #ports=(1533 1531 1543 1541)
    ports=($srv_ports)

for host in "\${hosts[@]}"; do
    for port in "\${ports[@]}"; do
        output=\$(nc -vz "\$host" "\$port" 2>&1)
        if echo "\$output" | grep -q 'Connected'; then
            status="Conectado"
        elif echo "\$output" | grep -q 'refused'; then
            status="** Rechazado **"
        else
            status="** Error **"
        fi
        printf "%-15s %-30s %-6s %-12s\n" "\$(hostname)" "\$host" "\$port" "\$status"
    done
done
ENDSSH

  else
    # Si falla la conexión SSH, muestra mensaje de error
    printf "%-15s %-30s %-6s %-12s\n" "$server" "---" "---" "** SSH ERROR **"
  fi

done

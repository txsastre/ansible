#!/bin/bash

# Pedir el usuario SSH
read -p "Usuario SSH: " USER

# Verificar que exista el archivo con IPs
if [ ! -f "listavm.txt" ]; then
    echo "❌ No se encontró el archivo listavm.txt"
    exit 1
fi

# Leer IPs del fichero, ignorando líneas vacías y comentarios
mapfile -t IPS < <(grep -vE '^\s*#|^\s*$' listavm.txt)

TIMEOUT=5

echo ""
echo "🔍 Verificando acceso SSH a cada IP..."
echo "--------------------------------------"

for ip in "${IPS[@]}"; do
    echo -n "🔗 $ip: "
    
    ssh -o BatchMode=yes -o ConnectTimeout=$TIMEOUT -o StrictHostKeyChecking=no "$USER@$ip" "exit" &>/dev/null

    if [ $? -eq 0 ]; then
        echo "✅ Conexión exitosa"
    else
        echo "❌ No se pudo conectar"
    fi
done


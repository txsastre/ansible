#!/bin/bash

read -p "Usuario SSH: " USER
read -s -p "Contraseña SSH: " PASS
echo

while IFS= read -r ip <&3; do
  sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no "$USER@$ip" "sudo chage -M 99999 -E -1 netreveal_user"
  echo "Hecho en $ip"
done 3< listavm.txt


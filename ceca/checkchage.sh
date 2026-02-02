#!/bin/bash

for ip in $(cat listavm.txt); do
  echo "$ip"
  ssh id3265@"$ip" 'sudo chage -l netreveal_user'
  echo "-----------------------------"
done


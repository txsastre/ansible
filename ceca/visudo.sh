---
- name: Eliminar fichero inv_hypervisors
  hosts: all
  become: yes   # Para ejecutar con privilegios de root, necesario para borrar en /etc/sudoers.d/
  tasks:
    - name: Borrar el fichero /etc/sudoers.d/inv_hypervisors
      file:
        path: /etc/sudoers.d/inv_hypervisors
        state: absent


## Exercise 2

1. `cd localdev/exercises/volume_permissions`
2. `# docker-compose up`
3. (from another shell) `# docker exec -it ldevex /bin/sh`
4. (from within the container) `~ $ ip addr > /opt/data/net_info.txt`
   /bin/sh: can't create /opt/data/net_info.txt: Permission denied ... Why?
5. (exit container)
6. (send stop signal to docker-compose)
7. `# chown -R 1001:1001 data/`
8. repeat steps 2-5
9. on host: `cat data/net_info.txt`
10. What just happened?

# copy certificate into /etc/pki/ca-trust/source/anchors/
# copy the rest of the commands to the root as well
docker build --tag centos-modsec .
docker kill modsecurity
docker rm modsecurity 2> /dev/null
gnome-terminal -- sh -c "docker run --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 8080:443 --name modsecurity -it centos-modsec /usr/sbin/init"
gnome-terminal -- sh -c "docker exec -it modsecurity /bin/bash"
~/scripts/keyboard_layout.sh

# copy certificate into /etc/pki/ca-trust/source/anchors/
# copy the rest of the commands to the root as well
docker build --tag centos-modsec .
docker kill modsecurity
docker rm modsecurity 2> /dev/null
gnome-terminal -- sh -c "docker run --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 8080:443 --name modsecurity -it centos-modsec /usr/sbin/init"
sleep 5
echo "copying certificate..."
# docker cp cagri.crt modsecurity:/etc/pki/ca-trust/source/anchors/
echo "creating nginx service file..."
# docker cp nginx.service modsecurity:/lib/systemd/system/nginx.service
echo "copying modsecurity..."
#docker cp ModSecurity-3-master modsecurity:/root/ModSecurityInstallation
# docker cp ModSecurity-nginx_refactoring modsecurity:/usr/src/ModSecurity
echo "copying script..."
# docker cp in-centos-setup.sh modsecurity:/root/in-centos-setup.sh
# docker cp nginx.conf modsecurity:/root/nginx.conf
echo "running script script..."
#docker exec -it modsecurity bash -c "/root/in-centos-setup.sh"

gnome-terminal -- sh -c "docker exec -it modsecurity /bin/bash"
~/scripts/keyboard_layout.sh

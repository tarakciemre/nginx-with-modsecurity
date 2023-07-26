# copy certificate into /etc/pki/ca-trust/source/anchors/
# copy the rest of the commands to the root as well
docker rm modsecurity 2> /dev/null
gnome-terminal -- sh -c "sudo docker run --privileged=true -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 8080:80 --name modsecurity -it centos-systemd /usr/sbin/init"
sleep 5
echo "copying certificate..."
docker cp cagri.crt modsecurity:/etc/pki/ca-trust/source/anchors/
echo "creating nginx service file..."
docker cp nginx.service modsecurity:/lib/systemd/system/nginx.service
echo "copying modsecurity..."
#docker cp ModSecurity-3-master modsecurity:/root/ModSecurityInstallation
docker cp ModSecurity-nginx_refactoring modsecurity:/root/ModSecurityNginx
echo "copying script..."
docker cp in-centos-setup.sh modsecurity:/root/in-centos-setup.sh
echo "running script script..."
docker exec -it modsecurity bash -c "/root/in-centos-setup.sh"



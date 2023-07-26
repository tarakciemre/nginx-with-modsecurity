# copy certificate into /etc/pki/ca-trust/source/anchors/
# copy the rest of the commands to the root as well
docker rm modsecurity 2> /dev/null
gnome-terminal -- sh -c "docker run --name modsecurity -it centos"
echo "copying certificate..."
docker cp cagri.crt modsecurity:/etc/pki/ca-trust/source/anchors/
echo "copying script..."
docker cp in-centos-setup.sh modsecurity:/root/in-centos-setup.sh
echo "running script script..."
docker exec -it modsecurity bash -c "/root/in-centos-setup.sh"



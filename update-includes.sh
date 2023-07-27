touch /etc/nginx/modsec_includes.conf
cat <<EOF>> /etc/nginx/modsec_includes.conf
include modsecurity.conf
include owasp-modsecurity-crs/crs-setup.conf
include owasp-modsecurity-crs/rules/*.conf
EOF

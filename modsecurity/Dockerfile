FROM centos:7

# ######################################################################################################################
# Setup systemd
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# ######################################################################################################################
# Network Setup
COPY cagri.crt /etc/pki/ca-trust/source/anchors/cagri.crt
RUN update-ca-trust

# ######################################################################################################################
# Installation
RUN yum update -y
RUN yum --enablerepo=extras install epel-release -y
RUN yum update -y
RUN yum install wget -y
RUN yum install gcc -y
RUN yum install pcre -y
RUN yum install pcre-devel -y
RUN yum install gd -y
RUN yum install gd-devel -y
RUN yum install libtool -y
RUN yum install git -y
RUN yum groupinstall -y "Development Tools"
RUN yum install libxml2 -y
RUN yum install libxml2-devel  -y
RUN yum install curl  -y
RUN yum install vim -y
RUN yum install curl-devel  -y
RUN yum install openssl  -y
RUN yum install openssl-devel -y
RUN yum install httpd -y
RUN yum install httpd-devel -y
# COPY nginx.conf /root/nginx.conf

WORKDIR /usr/src/
RUN git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git

WORKDIR /usr/src
RUN wget http://nginx.org/download/nginx-1.20.0.tar.gz
RUN tar -zxvf nginx-1.20.0.tar.gz && rm -f nginx-1.20.0.tar.gz

# ######################################################################################################################
# == Compile ModSecurity
# COPY ModSecurity-nginx_refactoring /usr/src/ModSecurity
WORKDIR /usr/src
RUN git clone -b nginx_refactoring https://github.com/SpiderLabs/ModSecurity.git
WORKDIR /usr/src/ModSecurity
RUN sed -i '/AC_PROG_CC/a\AM_PROG_CC_C_O' configure.ac
RUN sed -i '1 i\AUTOMAKE_OPTIONS = subdir-objects' Makefile.am
RUN ./autogen.sh
RUN ./configure --enable-standalone-module --disable-mlogc
RUN make

# ######################################################################################################################
# == Compile Nginx
RUN groupadd -r nginx
RUN useradd -r -g nginx -s /sbin/nologin -M nginx
 
WORKDIR /usr/src/nginx-1.20.0
RUN ./configure --user=nginx --group=nginx --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --add-module=/usr/src/ModSecurity/nginx/modsecurity --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module
# ./configure --user=nginx --group=nginx --add-module=/usr/src/ModSecurity/nginx/modsecurity --with-http_ssl_module
RUN make
RUN make install
 
# ######################################################################################################################
# === Setup Python dependencies

RUN yum install postgresql-libs -y
# RUN yum install python3 -y
RUN yum install python3-pip -y
RUN yum install python3-devel -y
# RUN yum install build-essential -y
# RUN yum install libssl-dev -y
# RUN yum install libffi-dev -y
RUN yum install python3-setuptools -y
RUN yum install libffi-devel -y
# RUN yum install python3-virtualenv
# .. causing problesm -> RUN pip3 install uwsgi
# RUN pip3 install virtualenv

# == install PYTHON
RUN mkdir /root/python-project
WORKDIR /root/python-project 
# RUN wget https://www.python.org/ftp/python/3.9.16/Python-3.9.16.tgz 
RUN wget https://www.python.org/ftp/python/3.8.16/Python-3.8.16.tgz
RUN tar xvf Python-3.8.16.tgz
WORKDIR /root/python-project/Python-3.8.16
RUN ./configure --enable-optimizations 
RUN make altinstall 
WORKDIR /root/python-project 
RUN rm Python-3.8.16.tgz 

RUN pip3.8 --cert /etc/pki/tls/cert.pem install --upgrade pip
RUN yum install postgresql-devel -y
RUN yum install gcc openssl-devel bzip2-devel libffi-devel zlib-devel -y
# RUN pip3.8 --cert /etc/pki/tls/cert.pem --default-timeout=50 install cmake

WORKDIR /root/python-project 
RUN python3.8 -m venv venv 
RUN source /root/python-project/venv/bin/activate
RUN pip3.8 --cert /etc/pki/tls/cert.pem install wheel
RUN pip3.8 --cert /etc/pki/tls/cert.pem install setuptools-rust

# install requirements
RUN git clone https://github.com/tarakciemre/flask-user-management flask
WORKDIR /root/python-project/flask
RUN pip3.8 --cert /etc/pki/tls/cert.pem install -r requirements.txt 
# RUN pip3.8 --cert /etc/pki/tls/cert.pem install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org pip setuptools
RUN pip3.8 --cert /etc/pki/tls/cert.pem install uwsgi
RUN pip3.8 --cert /etc/pki/tls/cert.pem install psycopg2

# RUN mkdir /var/lib/pgsql/11/data/flask/
VOLUME [ "/sys/fs/cgroup" ]

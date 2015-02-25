# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.16

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
VOLUME ["/srv/web"]

# install add-apt-repository
RUN sudo apt-get update
RUN sudo apt-get install -y software-properties-common python-software-properties

# install hhvm (stable)
RUN sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN sudo add-apt-repository 'deb http://dl.hhvm.com/ubuntu trusty main'
RUN sudo apt-get update
RUN sudo apt-get install -y hhvm

# install nginx
RUN sudo apt-get install -y nginx
ADD nginx.conf /etc/nginx/

RUN mkdir /etc/service/nginx
ADD nginx.sh /etc/service/nginx/run

RUN mkdir /etc/service/hhvm
ADD hhvm.sh /etc/service/hhvm/run

# set up nginx default site
ADD nginx-default /etc/nginx/sites-available/default

# create a directory with a sample index.hh file
RUN sudo mkdir -p /srv/web
ADD index.hh /srv/web/index.hh
ADD .hhconfig /srv/web/.hhconfig

RUN sudo /usr/share/hhvm/install_fastcgi.sh

# Clean up APT when done.
RUN apt-get -y clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# expose port 80
EXPOSE 80

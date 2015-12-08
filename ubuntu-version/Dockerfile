FROM i686/ubuntu
MAINTAINER Boutry Thomas "thomas.boutry@x3rus.com"

# install apps 
RUN    apt-get update &&  apt-get install -y vim \
        bc  \
        openssh-server \
        man \
        git \
        dnsutils \
        wget \
        sudo \
        net-tools \
        iptables \
        psmisc \
        telnet \
        whois \
        curl \
        git \
        screen \
        byobu \
        unzip \
        lsof \
        locales \
        software-properties-common
 
RUN apt-get clean all

## Set timezone
#
RUN echo "America/Montreal" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

# unable regular user to use ping
#RUN chmod u+s /usr/bin/ping

# Create default user "BOB" with password toto
RUN useradd -s /bin/bash -m  bob && \
    echo "bob:toto" | chpasswd && \
    usermod -G sudo bob

# use Supervisor  to start services 
RUN apt-get install -y  supervisor
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Remove DNS validation for ssh
RUN echo "\n UseDNS no" >> /etc/ssh/sshd_config && \
        sed -e 's/PrintLastLog yes/PrintLastLog no/' -i /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/bin/supervisord"]


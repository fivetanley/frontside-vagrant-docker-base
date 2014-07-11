FROM phusion/baseimage
RUN ["apt-get", "update"]
RUN apt-get install -y ca-certificates man build-essential wget 
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update
#RUN apt-get -y upgrade
RUN apt-get install -y postgresql-9.3 postgresql-contrib-9.3 postgresql-client-9.3

# Create passwordless vagrant user that can sudo
EXPOSE 5432
RUN ["adduser", "vagrant"]
RUN ["passwd", "-d", "-u", "vagrant"]
RUN ["usermod", "-a", "-G", "sudo", "vagrant"]
RUN echo '%sudo ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant

# Allow Vagrant login
ADD vagrant.pub /home/vagrant/.ssh/authorized_keys

RUN service postgresql start && su postgres --command 'createuser -s -w vagrant' && service postgresql stop

# Install RVM
USER vagrant
ENV RVM_PATH /home/vagrant/.rvm
ENV rvm_path /home/vagrant/.rvm
ENV HOME /home/vagrant
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN bash -l -c 'rvm install 1.9.3'
RUN bash -l -c 'rvm install 2.0'
RUN bash -l -c 'rvm install 2.1'
RUN bash -l -c 'rvm --default use 2.1'
#RUN bash -l -c 'sudo -u postgres createuser -s -w vagrant'
# Install NVM and Node Utils
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.7.0/install.sh | sh
RUN bash -l -c 'nvm install 0.10'
RUN bash -l -c 'nvm alias default 0.10'
RUN bash -l -c 'npm install -g grunt-cli karma-cli bower'
ADD .bowerrc /home/vagrant/.bowerrc

USER root 
CMD service postgresql start && /sbin/my_init
USER root
EXPOSE 8000

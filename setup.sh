sudo apt-get update -y

sudo apt-get install -y nmon htop tmux vim python-dev python-pip

wget -qO- https://get.docker.com/ | sh

sudo pip install docker-compose

cd /home/vagrant/lameland

sudo docker-compose build

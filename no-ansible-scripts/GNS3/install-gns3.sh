#Instalar GNS3

sudo add-apt-repository ppa:gns3/ppa
sudo apt-get update
sudo apt-get install gns3-gui gns3-server

gns3 --version

# Cambiar los permisos de ubridge

sudo chmod 755 /usr/bin/ubridge

#Descargar las maquinas virtuales de los dispositivos y la configuración

pushd
cd $HOME

wget --no-check-certificate 'https://drive.google.com/file/d/1HIBq01ld7TeI4q40BCKMQHj1T9Q9gX70/view?usp=sharing' -O config_gns3.ini

wget --no-check-certificate 'https://drive.google.com/file/d/1fYDewfNvOkNPBQURb0WQ4N1-XX_AxyHN/view?usp=sharing' -O GNS3.tar.gz

tar xzvf GNS3.tar.gz

popd
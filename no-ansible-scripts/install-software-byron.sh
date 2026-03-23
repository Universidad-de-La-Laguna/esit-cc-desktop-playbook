

apt update
apt install software-properties-common
add-apt-repository ppa:deadsnakes/ppa
apt update
apt install python3.9
python3.9 --version

apt install -y g++--12  pypy3


update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
update-alternatives --set java  /usr/lib/jvm/java-17-openjdk-amd64/bin/java



### La URL del servidores : https://ada-byron.uib.es/
### IP servidor: 130.206.30.31 (también tiene como alias olimpiada.uib.es)
### 
### Versiones del lenguaje en el servidor
### C
### $ gcc --version
### gcc (Debian 12.2.0-14) 12.2.0
### 
### C++
### $ g++ --version
### g++ (Debian 12.2.0-14) 12.2.0
### Configurado para que compile C++20
### Por si a algún equipo le puede interesar, este es el comando de compilación: g++ -x c++ -std=c++20 -Wall -O2 -static -pipe -o 
### 
### JAVA
### $ javac -version
### javac 17.0.14
### 
### PYTHON
### $ pypy3 --version
### Python 3.9.16 (7.3.11+dfsg-2+deb12u3, Dec 30 2024, 22:36:23)
### [PyPy 7.3.11 with GCC 12.2.0]

#!/bin/bash
# Instalación de Spark
# Pasos seguidos en https://howtoforge.es/como-instalar-apache-spark-en-ubuntu-22-04/


# apt-get install default-jdk curl -y
cd /opt/
mv spark spark.deprecated

#wget https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz
wget https://dlcdn.apache.org/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz

tar xvf spark-3.5.1-bin-hadoop3.tgz
rm -f spark-3.5.1-bin-hadoop3.tgz
ln -s spark-3.5.1-bin-hadoop3 spark
useradd spark

mkdir -p /opt/spark/logs # bug, sino no arranca el servicio
chown -R spark:spark /opt/spark
chmod -R a+w /opt/spark

cat > /etc/profile.d/spark.sh <<'EOF'
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
EOF

source /etc/profile.d/spark.sh

cat > /etc/systemd/system/spark-master.service << 'EOF'
[Unit]
Description=Apache Spark Master
After=network.target

[Service]
Type=forking
User=spark
Group=spark
ExecStart=/opt/spark/sbin/start-master.sh
ExecStop=/opt/spark/sbin/stop-master.sh

[Install]
WantedBy=multi-user.target

EOF

cat > /etc/systemd/system/spark-slave.service << 'EOF'
[Unit]

Description=Apache Spark Slave

After=network.target

[Service]
Type=forking
User=spark
Group=spark
ExecStart=/opt/spark/sbin/start-slave.sh spark://your-server-ip:7077
ExecStop=/opt/spark/sbin/stop-slave.sh

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl start spark-master
systemctl enable spark-master
#systemctl status spark-master

systemctl start spark-slave
systemctl enable spark-slave
#systemctl status spark-slave

# ejemplos
cd /opt
wget https://raw.githubusercontent.com/Universidad-de-La-Laguna/esit-cc-desktop-playbook/master/no-ansible-scripts/EjemploSpark01.tar.gz
tar xzvf EjemploSpark01.tar.gz

#
# pyspark
# /opt/EjemplosSpark01/ej01_count.py 
cat > /opt/EjemplosSpark01/ej01_count.py<<'EOF'
#
#
# Tutorialspoint - PySpark; Learn Pyspark
#
# ----------------------------------------count.py---------------------------------------
from pyspark import SparkContext
sc = SparkContext("local", "count app")
words = sc.parallelize (
   ["scala", 
   "java", 
   "hadoop", 
   "spark", 
   "akka",
   "spark vs hadoop", 
   "pyspark",
   "pyspark and spark"]
)
counts = words.count()
print ("Number of elements in RDD -> %i" % (counts))
EOF

# spark-submit /opt/EjemplosSpark01/ej01_count.py
# URL de conexión http://cc131c1:8080





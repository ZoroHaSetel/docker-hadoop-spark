FROM debian:bullseye-slim


RUN apt update
RUN apt-get update

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
openjdk-11-jdk \
net-tools \
curl \
gnupg \
libsnappy-dev \
python3 \
nano \
python3-pip \
&& rm -rf /var/lib/apt/lists/*


RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN echo 'deb http://archive.debian.org/debian/ stretch main contrib non-free '> /etc/apt/sources.list

RUN echo 'deb http://archive.debian.org/debian-security/ stretch/updates main contrib non-free' >>  /etc/apt/sources.list


ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/

RUN curl -O https://dist.apache.org/repos/dist/release/hadoop/common/KEYS

RUN gpg --import KEYS

ENV HADOOP_VERSION 3.3.6
ENV HADOOP_URL https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz


RUN set -x \
&& curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
&& curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc \
&& gpg --verify /tmp/hadoop.tar.gz.asc \
&& tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
&& rm /tmp/hadoop.tar.gz*

RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop

RUN mkdir /opt/hadoop-$HADOOP_VERSION/logs

RUN mkdir /hadoop-data

ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR /etc/hadoop
ENV MULTIHOMED_NETWORK 1
ENV USER root
ENV PATH $HADOOP_HOME/bin/:$PATH

# install python library

RUN pip3 install mrjob 

ADD entrypoint.sh /entrypoint.sh


RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

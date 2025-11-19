FROM bde2020/hadoop-base:latest

ENV PIG_VERSION 0.17.0
ENV PIG_URL https://www.apache.org/dist/pig/pig-$PIG_VERSION/pig-$PIG_VERSION.tar.gz

RUN set -x \
    && curl -fSL "$PIG_URL" -o /tmp/pig.tar.gz \
    && tar -xvf /tmp/pig.tar.gz -C /opt/ \
    && rm /tmp/pig.tar.gz

ENV PIG_HOME /opt/pig-$PIG_VERSION
ENV PATH $PIG_HOME/bin/:$PATH

RUN chmod +x $PIG_HOME/bin/pig

WORKDIR /root

CMD ["/bin/bash"]

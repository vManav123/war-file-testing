FROM ubuntu:19.04

LABEL maintainer Nadeva<contact@nadeva.fr>

EXPOSE 8080
EXPOSE 9000

WORKDIR /root/workdir
COPY workdir /root/workdir_complete
RUN apt-get update && apt-get install -y \
  wget \
  curl \
  unzip \
  zip \
  git \
  nano \
  vim
RUN curl -s "https://get.sdkman.io" | bash
RUN /bin/bash -c "source '/root/.sdkman/bin/sdkman-init.sh' && \
                  sdk install java 8.0.222-amzn && \
                  sdk install java 11.0.4-amzn && \
                  sdk install maven 3.6.1"
ENV JAVA_HOME="/root/.sdkman/candidates/java/current"


RUN mkdir /root/tools
RUN wget https://download.jboss.org/wildfly/17.0.1.Final/wildfly-17.0.1.Final.tar.gz -P /root/tools
RUN cd /root/tools && tar -xzvf wildfly-17.0.1.Final.tar.gz
RUN cd /root/tools && rm wildfly-17.0.1.Final.tar.gz

RUN sed -i '/inet-address/c\<any-address/>' /root/tools/wildfly-17.0.1.Final/standalone/configuration/standalone.xml

ENV PATH="/root/tools/wildfly-17.0.1.Final/bin:${PATH}"
RUN /root/tools/wildfly-17.0.1.Final/bin/add-user.sh admin admin -e
RUN mkdir /root/repository
RUN cd /root/repository && git clone --depth 1 https://github.com/nadeva/javaee-bookstore.git

#RUN cd /root/repository/javaee-bookstore && ./mvnw clean package
#RUN cd /root/repository/javaee-bookstore && ./mvnw clean

RUN wget http://downloads.jboss.org/forge/releases/3.9.4.Final/forge-distribution-3.9.4.Final-offline.zip -P /root/tools
RUN cd /root/tools && unzip forge-distribution-3.9.4.Final-offline.zip
RUN cd /root/tools && rm forge-distribution-3.9.4.Final-offline.zip
ENV PATH="/root/tools/forge-distribution-3.9.4.Final/bin:${PATH}"

RUN apt-get install -y build-essential libz-dev
RUN wget https://github.com/oracle/graal/releases/download/vm-19.1.1/graalvm-ce-linux-amd64-19.1.1.tar.gz -P /root/tools
RUN cd /root/tools && tar -xzvf graalvm-ce-linux-amd64-19.1.1.tar.gz
RUN cd /root/tools && rm graalvm-ce-linux-amd64-19.1.1.tar.gz
ENV GRAALVM_HOME="/root/tools/graalvm-ce-linux-amd64-19.1.1"
ENV PATH="/root/tools/graalvm-ce-linux-amd64-19.1.1/bin:${PATH}"
RUN /root/tools/graalvm-ce-linux-amd64-19.1.1/bin/gu install native-image


CMD /bin/bash

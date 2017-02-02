FROM centos

RUN yum -y --setopt=tsflags=nodocs install wget git tar which curl tree java-1.8.0-openjdk-devel net-utils createrepo && yum -y clean all

ENV SONATYPE_WORK=/sonatype-work JAVA_HOME=/etc/alternatives/java_sdk_1.8.0_openjdk NEXUS_VERSION=2.14.1-01 CONTEXT_PATH=/nexus MAX_HEAP=768m MIN_HEAP=256m JAVA_OPTS="-server -Djava.net.preferIPv4Stack=true" LAUNCHER_CONF="./conf/jetty.xml ./conf/jetty-requestlog.xml" 
          
RUN mkdir -p /opt/sonatype/nexus \
  && curl --fail --silent --location --retry 3 \
    https://download.sonatype.com/nexus/oss/nexus-${NEXUS_VERSION}-bundle.tar.gz \
  | gunzip \
  | tar x -C /tmp nexus-${NEXUS_VERSION} \
  && mv /tmp/nexus-${NEXUS_VERSION}/* /opt/sonatype/nexus/ \
  && rm -rf /tmp/nexus-${NEXUS_VERSION}

RUN useradd -r -u 200 -m -c "nexus role account" -d ${SONATYPE_WORK} -s /bin/false nexus

VOLUME ${SONATYPE_WORK}

EXPOSE 8081

WORKDIR /opt/sonatype/nexus

USER 200

CMD ${JAVA_HOME}/bin/java \
  -Dnexus-work=${SONATYPE_WORK} -Dnexus-webapp-context-path=${CONTEXT_PATH} \
  -Xms${MIN_HEAP} -Xmx${MAX_HEAP} \
  -cp 'conf/:lib/*' \
  ${JAVA_OPTS} \
  org.sonatype.nexus.bootstrap.Launcher ${LAUNCHER_CONF}

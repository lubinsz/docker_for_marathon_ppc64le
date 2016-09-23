#
# This is the official docker image that is used for production deployments of docker.
#
# It has the marathon startup script as entrypoint.
#
# It will reresolve all dependencies on every change (as opposed to Dockerfile.development)
# but it ultimately results in a smaller docker image.
#
FROM powerkvm/dumb-init-ppc64le 

RUN yum -y install cyrus-sasl-md5 subversion

RUN rpm -ivh http://pokgsa.ibm.com/projects/i/ibm-mesos/power/mesos-1.0.0-2016080804.ael7b.ppc64le.rpm

RUN yum -y install git  && \
    git clone https://github.com/mesosphere/marathon.git /marathon 

RUN cd /marathon && git checkout v1.1.1 && \
    yum -y install java-1.8.0-openjdk  install java-1.8.0-openjdk-devel wget && \
    mkdir -p /usr/local/bin && \
    wget -P /usr/local/bin/ http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.11/sbt-launch.jar && \
    cp /marathon/project/sbt /usr/local/bin && chmod +x /usr/local/bin/sbt && \
    sbt -Dsbt.log.format=false assembly && \
    mv $(find target -name 'marathon-assembly-*.jar' | sort | tail -1) ./ && \
    rm -rf target/* ~/.sbt ~/.ivy2 && \
    mv marathon-assembly-*.jar target && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/marathon/bin/start"]

FROM openjdk:8-jre-alpine
ADD [ "https://github.com/alibaba/canal/releases/download/canal-1.1.4/canal.deployer-1.1.4.tar.gz", "/opt/canal-server/" ]
WORKDIR /opt/canal-server
EXPOSE 11110 11112
COPY ["entrypoint.sh", "/"]
RUN apk add bash tzdata \
  && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && apk del tzdata
VOLUME ["/opt/canal-server/logs", "/opt/canal-server/conf"]
ENTRYPOINT /entrypoint.sh
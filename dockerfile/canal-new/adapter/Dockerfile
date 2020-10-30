FROM openjdk:8-jre-alpine
RUN echo "Asia/Shanghai" > /etc/timezone
ADD canal.adapter-1.1.4  /opt/adapter/
WORKDIR /opt/adapter
#COPY canal.adapter-1.1.4/conf /opt/adapter/conf/
COPY ["entrypoint.sh", "/"]
RUN chmod 777 /entrypoint.sh
ENTRYPOINT /entrypoint.sh

# https://www.cnblogs.com/caibao666/p/12056042.html
FROM centos:6.6

#设置时钟
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo ZONE=\"Asia/Shanghai\" > /etc/sysconfig/clock

#更新yum源
#RUN rm -rf /etc/yum.repos.d/*.repo
#COPY CentOS6-Base-163.repo /etc/yum.repos.d/
#RUN yum clean all


#创建用户
RUN groupadd -g 2500 canal; useradd -u 2501 -g canal -d /home/canal -m canal
RUN echo canal:De@2018er | chpasswd; echo root:dockerroot | chpasswd

# 安装相关包
RUN yum -y install wget vi openssl.x86_64 glibc.x86_64 tar inetutils-ping net-tools telnet which file

# 配置java环境变量
#COPY jdk-8u201-linux-x64.tar.gz /opt
#RUN tar -zvxf /opt/jdk-8u201-linux-x64.tar.gz -C /opt && \
#        rm -rf /opt/jdk-8u201-linux-x64.tar.gz && \
#                        chmod -R 755 /opt/jdk1.8.0_201 && \
#                                        chown -R root:root /opt/jdk1.8.0_201

RUN  yum install java-1.8.0-openjdk.x86_64 -y
RUN JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.191.b12-1.el7_6.x86_64 && JRE_HOME=$JAVA_HOME/jre && CLASS_PATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib && PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin && export JAVA_HOME JRE_HOME CLASS_PATH PATH

## https://www.cnblogs.com/yuwensong/p/11474032.html

#RUN echo 'export JAVA_HOME=/opt/jdk1.8.0_201' >> /etc/profile
#RUN echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile
#RUN echo 'export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH' >> /etc/profile
#RUN echo 'export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH' >> /etc/profile
#RUN source /etc/profile

#安装中文包
RUN yum install kde-l10n-Chinese -y
RUN yum install glibc-common -y
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
#ENV JAVA_HOME /opt/jdk1.8.0_201
#ENV PATH $PATH:$JAVA_HOME/bin
ENV LANG zh_CN.UTF-8
ENV LC_ALL zh_CN.UTF-8

RUN yum clean all


#ADD 复制canal-server程序
ADD canal-server /home/canal/
RUN chmod 755 /home/canal/bin

#启动程序
WORKDIR /home/canal/bin
RUN chmod 777 /home/canal/bin/restart.sh
RUN chmod 777 /home/canal/bin/startup.sh
RUN chmod 777 /home/canal/bin/stop.sh
RUN chmod 777 /home/canal/bin/config.sh
CMD /home/canal/bin/config.sh &

FROM redis:3.2

MAINTAINER Johan Andersson <Grokzen@gmail.com>

RUN echo "deb http://mirrors.aliyun.com/debian wheezy main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian wheezy main contrib non-free" >> /etc/apt/sources.list  && \
    echo "deb http://mirrors.aliyun.com/debian wheezy-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian wheezy-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security wheezy/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian-security wheezy/updates main contrib non-free" >> /etc/apt/sources.list

# Some Environment Variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -yqq \
      net-tools supervisor ruby rubygems locales gettext-base wget && \
    apt-get clean -yqq

# # Ensure UTF-8 lang and locale
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN gem install redis -v 3.3.3

RUN apt-get install -y gcc make g++ build-essential libc6-dev tcl git supervisor ruby

ARG redis_version=3.2.9

RUN wget -qO redis.tar.gz http://download.redis.io/releases/redis-${redis_version}.tar.gz \
    && tar xfz redis.tar.gz -C / \
    && mv /redis-$redis_version /redis

RUN (cd /redis && make)

RUN mkdir /redis-conf
RUN mkdir /redis-data

#COPY ./docker-data/redis-cluster.tmpl /redis-conf/redis-cluster.tmpl
#COPY ./docker-data/redis.tmpl /redis-conf/redis.tmpl

# Add supervisord configuration
#COPY ./docker-data/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add startup script
COPY ./docker-data/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

EXPOSE 7000 7001

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["redis-cluster"]

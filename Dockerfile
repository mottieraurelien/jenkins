FROM alpine:latest

# Team responsible for this Dockerfile :
MAINTAINER mottieraurelien <mottier.aurelien@gmail.com>

# check PID jenkins GID too
ENV USER=jenkins
ENV GROUP=jenkins
ENV HOME=/home/jenkins
ENV PROFILE=/etc/profile
ENV UID=12345
ENV GID=23456

# Defining the working directory for jenkins :
WORKDIR $HOME

# Creating a user jenkins :
RUN addgroup -g "$GID" -S "$GROUP"
RUN adduser --disabled-password --gecos "" --home "$HOME" --ingroup "$GROUP" --uid "$UID" "$USER"

# Defining APK HK mirrors (COPY a file that contains all repos) :
RUN echo "http://mirror.xtom.com.hk/alpine/latest-stable/main" > /etc/apk/repositories \
    && echo "http://mirror.xtom.com.hk/alpine/latest-stable/community" >> /etc/apk/repositories

# Installing tools :
RUN apk --no-cache add \
    bash ca-certificates curl git grep gzip jq openssh-client-common openssl openrc python3 py3-pip sed tar unzip wget which zip \
    docker docker-compose git-lfs helm maven openjdk8 openjdk11

# Adding jenkins to the docker group so that it does not require root privileges to run docker commands :
RUN addgroup "$USER" docker

# Adding CA certificates :
RUN mkdir mkdir -p /etc/certificates/
# COPY .. /etc/certificates/
# COPY .. /etc/certificates/
# COPY .. /etc/certificates/
# RUN update-ca-..

# Installing Kubernetes (regular COPY with +x already set) :
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && mv ./kubectl /usr/local/bin/ \
    && chmod +x /usr/local/bin/kubectl
# Install key to get access to DEV and PROD cluters
# Set DEV context by default

# Defining JDK aliases to ease switching between JDKs :
RUN echo "alias java8=\"export JAVA_HOME=`/usr/lib/jvm/java-1.8-openjdk/`; java -version\"" >> $PROFILE
RUN echo "alias java11=\"export JAVA_HOME=`/usr/lib/jvm/java-11-openjdk/`; java -version\"" >> $PROFILE
RUN echo "alias javalts=\"export JAVA_HOME=`/usr/lib/jvm/java-11-openjdk/`; java -version\"" >> $PROFILE

# Defining Maven settings :
RUN mkdir -p $HOME/.m2/repository
# COPY settings.xml $HOME/.m2
# COPY settings.xml /usr/share/java/maven-3/conf/
# RUN wget m2 repo and extract in $HOME/.m2/repository

# Defining Python settings :
RUN mkdir -p $HOME/.pip
# COPY / RUN ...

# Installing Python packages :
# COPY requirements.txt $HOME/
# RUN pip install -r $HOME/requirements.txt && rm -f $HOME/requirements.txt

# Fixing ownership on a bunch of folders :
RUN chown -R $USER:$GROUP $HOME/
# RUN chown -R $USER:$GROUP /usr/share/java/maven-3/
# RUN chown -R $USER:$GROUP /usr/lib/jvm/

# Starting docker :
RUN rc-update add docker

# Housekeeping :
RUN rm -rf /var/cache/apk/*

# Switching to the jenkins user (no need root anymore) :
USER $USER

# Holding the container so that I can connect and run a few checks :
ENTRYPOINT ["tail", "-f", "/dev/null"]
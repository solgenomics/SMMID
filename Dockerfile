
### Dockerfile for SMID-DB.org

FROM debian:buster

LABEL maintainer="lam87@cornell.edu"

EXPOSE 8088

RUN mkdir -p  /home/production/local-lib


# install prerequisites

RUN apt-get update && apt-get -y install apt-utils imagemagick screen nmap git lynx postgresql postgresql-server-dev-11 cpanminus build-essential perl-doc curl

RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -

# Add the desired NodeSource repository
ENV VERSION=node_10.x

RUN echo "deb https://deb.nodesource.com/node_10.x  buster main" | tee /etc/apt/sources.list.d/nodesource.list
RUN echo "deb-src https://deb.nodesource.com/node_10.x buster main" | tee -a /etc/apt/sources.list.d/nodesource.list

# Update package lists and install Node.js
RUN apt-get update && apt-get install nodejs -y

RUN git clone https://github.com/solgenomics/SMMID /home/production/SMMID

WORKDIR /home/production/SMMID

COPY build.sh /
 
RUN bash /build.sh

COPY entrypoint.sh /
COPY smmid_local.conf.docker /home/production/SMMID/smmid_local.conf

RUN git checkout relational_smid

ENV PERL5LIB=/home/production/SMMID/lib:/home/production/local-lib/lib/perl5
ENV CATALYST_HOME=/home/production/SMMID

ENTRYPOINT bash /entrypoint.sh


	   

FROM ubuntu:precise

# Update to force a full rebuild
ENV LAST_UPDATED 2014-03-08

# Install RVM and ruby 2.0.0
RUN apt-get update
RUN apt-get -y install curl openssl

# For nokogiri
RUN apt-get install -y build-essential libxslt-dev libxml2-dev


RUN curl -L https://get.rvm.io | bash -s stable

RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc

RUN /bin/bash -l -c 'rvm install 2.0.0-p353'
RUN /bin/bash -l -c 'rvm use 2.0.0-p353 --default'

ENV PATH /usr/local/rvm/bin:/usr/local/rvm/rubies/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


# Install bundler
RUN gem install bundler


# Sync the current code
# Will need to be rebuilt to be updated
ADD . /code


# Install the gem dependencies
RUN cd /code && bundle install


# RUN the dashboard (default : port 3030)
# EXPOSE 3030
CMD cd /code && bundle exec dashing start

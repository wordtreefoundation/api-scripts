FROM dockerfile/ruby

ADD app /app
ADD run.sh /app/run.sh

WORKDIR /app

RUN bundle install

EXPOSE 8080

# Make library-on-disk available
VOLUME ["/library"]
ENV LIBRARY /library

# We expect a "--link beanstalkd:beanstalkd" to point us to the Beanstalkd
# container (i.e. via /etc/hosts)
ENV BEANSTALKD beanstalkd

# Register at chaNginx server
ENV APP_PORT 8080
ENV APP_NAME api-scripts
ENV APP_MOUNT /api/scripts
ENV APP_PASSWD_FILE api.htpasswd

CMD ./run.sh

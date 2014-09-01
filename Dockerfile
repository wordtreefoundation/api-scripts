FROM dockerfile/ruby

ADD app/Gemfile /app/Gemfile
ADD app/Gemfile.lock /app/Gemfile.lock
WORKDIR /app

RUN bundle install

ADD app /app
ADD run.sh /app/run.sh

EXPOSE 8080

# Make library-on-disk available
VOLUME ["/library"]
ENV LIBRARY /library

# Make scripts' log dir available
VOLUME ["/logs"]
ENV LOGDIR /logs

# We expect a "--link beanstalkd:beanstalkd" to point us to Beanstalkd
ENV BEANSTALK_URL beanstalk://beanstalkd/

# We expect a "--link rethinkdb:rethinkdb" to point us to RethinkDB
ENV RDB_HOST rethinkdb

# Register at chaNginx server
ENV APP_PORT 8080
ENV APP_NAME api-scripts
ENV APP_MOUNT /api/scripts
ENV APP_PASSWD_FILE api.htpasswd

CMD ./run.sh

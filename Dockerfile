FROM iron/ruby
ADD run.rb /
ENV BUILD_PACKAGES curl-dev ruby-dev build-base
# Update and install base packages
RUN apk update && apk upgrade && apk add bash $BUILD_PACKAGES
RUN gem install --no-ri --no-rdoc json logstash-logger 
RUN chmod u+x /run.rb
CMD ["/run.rb"]

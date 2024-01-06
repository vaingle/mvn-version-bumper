FROM maven:3.6.3-jdk-11
COPY versioning.sh /versioning.sh
RUN chmod +x /versioning.sh

ENTRYPOINT ["/versioning.sh"]

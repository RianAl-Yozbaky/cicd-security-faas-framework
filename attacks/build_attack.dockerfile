FROM python:3.11
USER root
RUN curl http://example.com/install.sh | sh

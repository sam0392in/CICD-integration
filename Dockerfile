FROM ubuntu:latest
MAINTAINER Samarth Kanungo
USER root

# Install required utilities
RUN apt-get update \
        && apt-get install curl -y \
        && apt install software-properties-common -y \
        && apt install python3 -y \
        && apt-get install python3-pip -y


# CREATE USER
ARG user=sam
ARG group=sam
ARG uid=1000
ARG gid=1000
ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group}
RUN useradd -c "sam" -d $HOME -u ${uid} -g ${gid} -m ${user}


# Copy application and requirements
COPY app.py /home/app.py
COPY requirements.txt /home/requirements.txt
COPY templates /home/templates

# Give permissions for application
RUN chmod 755 /home/app.py \
    && chmod 755 /home/requirements.txt

# Install Requirements
RUN pip3 install -r /home/requirements.txt

# Copy Dockerfile for reference
COPY Dockerfile /Dockerfile

# Expose application port
EXPOSE 5000

USER 1000

# Entry Command when Container Starts
CMD ["/usr/bin/python3", "/home/app.py"]

# Use an official Python runtime as the base image
FROM python:3.9-slim-bookworm

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends --assume-yes \
      exiftool \
      nodejs \
      npm \
      inotify-tools

RUN npm i -g immich

# Set environment variables
ENV FLASK_APP app.py
ENV FLASK_RUN_HOST 0.0.0.0
ENV FLASK_ENV production
ENV SECRET_KEY=$SECRET_KEY_ARG

# Enviroment variables for Immich server
ENV API_KEY=
ENV SERVER_URL=

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install the required packages
RUN pip install --no-cache-dir -r requirements.txt

# Install Gunicorn
RUN pip install --no-cache-dir gunicorn

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Create /app/destination if it doesn't exist
RUN mkdir -p /app/destination

# Give execute permissions to the scripts
RUN chmod +x entrypoint.sh immich-upload.sh

# Use our custom entrypoint
ENTRYPOINT ["./entrypoint.sh"]
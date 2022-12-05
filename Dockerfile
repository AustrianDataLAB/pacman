FROM node:latest

# Create a pacman user
RUN useradd -ms /bin/bash pacman

# Create app directory
RUN mkdir -p /usr/src/app \
 && chown -R pacman:pacman /usr/src/app
WORKDIR /usr/src/app

# Clone game source code
COPY src .

# Install app dependencies
RUN npm install

# Expose port 8080
EXPOSE 8080
USER pacman
# Run container
CMD ["npm", "start"]

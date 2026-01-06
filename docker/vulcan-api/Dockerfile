# docker/vulcan-api/Dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files first for caching (works if they exist)
COPY package*.json ./
RUN if [ -f package.json ]; then npm ci; fi

# Copy the rest of the repo into the image
COPY . .

EXPOSE 3000

# Prefer npm start if package.json exists, else fallback to node server.js
CMD sh -c "if [ -f package.json ]; then npm start; else node server.js; fi"
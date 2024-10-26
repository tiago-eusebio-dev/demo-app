# Stage 1: Build the Angular app

FROM node:20 AS build
LABEL author="Tiago Eusébio"
# Set the working directory
WORKDIR /app
# Copy package.json and package-lock.json
COPY package*.json ./
# Install Angular CLI and dependencies
RUN npm i
# Copy the Angular app
COPY . .
# Build the Angular app
RUN npm run build


# Stage 2: Serve the app with Nginx

FROM nginx:alpine
# Create a volume for caching Nginx data
VOLUME /var/cache/nginx
# Copy the built Angular app from the build stage
COPY --from=build app/dist/demo-app/browser /usr/share/nginx/html
# Copy custom Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Expose port 80
EXPOSE 80
# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

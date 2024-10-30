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

# Stage 2: Install Certbot and obtain SSL certificates

FROM certbot/certbot AS certbot
# Replace `example.com` and `your.email@example.com` with your domain and email
# Run Certbot to generate SSL certificates (manual mode for first time; requires DNS TXT validation or similar)
# To automate, you could integrate Certbot DNS plugins for automated cert creation
RUN certbot certonly --standalone -d tfae.ddns.net --email tfaeusebio@hotmail.com --agree-tos --no-eff-email --non-interactive

# Stage 3: Serve the app with Nginx with SSL

FROM nginx:alpine
# Create a volume for caching Nginx data
VOLUME /var/cache/nginx
# Copy the built Angular app from the build stage
COPY --from=build app/dist/demo-app/browser /usr/share/nginx/html
# Copy custom Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy SSL certificates from Certbot stage to Nginx
COPY --from=certbot /etc/letsencrypt/live/tfae.ddns.net/fullchain.pem /etc/ssl/certs/nginx-cert.pem
COPY --from=certbot /etc/letsencrypt/live/tfae.ddns.net/privkey.pem /etc/ssl/private/nginx-key.pem
# Expose both HTTP and HTTPS ports
EXPOSE 80 443
# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

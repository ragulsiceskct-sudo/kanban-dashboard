
# ==========================================
# Stage 1: Build React application
# ==========================================
FROM node:24-alpine AS build

WORKDIR /app

# Copy dependency files first for better layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application source code
COPY . .

# Create production build
RUN npm run build


# ==========================================
# Stage 2: Production runtime
# ==========================================
FROM nginx:alpine AS runtime

# Remove default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Add our custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy only production build artifacts
COPY --from=build /app/dist /usr/share/nginx/html

# Set permissions for non-root Nginx user
RUN chown -R nginx:nginx /usr/share/nginx/html \
    && touch /tmp/nginx.pid \
    && chown nginx:nginx /tmp/nginx.pid \
    && mkdir -p /tmp/client_temp /tmp/proxy_temp /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp \
    && chown -R nginx:nginx /tmp/client_temp /tmp/proxy_temp /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp

# Run as non-root user
USER nginx

# Application port
EXPOSE 8080

# Container health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/ || exit 1

CMD ["nginx", "-g", "daemon off;"]

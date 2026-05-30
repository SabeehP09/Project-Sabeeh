# Stage 1: Build dependencies
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files and install dependencies
COPY src/package*.json ./
RUN npm ci --omit=dev

# Stage 2: Production image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Create a non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Ensure /app is writable by nodejs (needed for counter.json)
RUN chown nodejs:nodejs /app

# Copy dependencies from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Copy application source
COPY --chown=nodejs:nodejs src/ ./

# Switch to non-root user
USER nodejs

# Expose the application port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["node", "app.js"]

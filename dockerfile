# Use Node.js base image
FROM node:18

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies and generate Prisma client
RUN npm install
RUN npx prisma generate

# Copy the rest of the code
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
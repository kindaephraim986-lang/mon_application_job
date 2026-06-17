FROM node:20-slim

WORKDIR /usr/src/app

COPY package.json package-lock.json ./
RUN npm install --production

COPY . .
RUN mkdir -p uploads

EXPOSE 3001

CMD ["npm", "start"]

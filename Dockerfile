FROM node:20-bullseye AS build

WORKDIR /app

# EC2(약 1GB RAM)에서도 OOM을 덜 유발하도록 Node 힙 상한을 보수적으로 설정
ENV NODE_OPTIONS="--max-old-space-size=512"

COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY . .
RUN npm run build


FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
    
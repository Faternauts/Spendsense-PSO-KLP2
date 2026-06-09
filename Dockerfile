# STAGE 1: Build the Flutter Web App
FROM ubuntu:22.04 AS build-env

RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter channel stable && flutter upgrade

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

# CACHE-BUSTING TRICK: Memaksa browser muat ulang versi terbaru
RUN sed -i -e "s/main.dart.js/main.dart.js?v=$(date +%s)/g" build/web/index.html
RUN sed -i -e "s/flutter_bootstrap.js/flutter_bootstrap.js?v=$(date +%s)/g" build/web/index.html

# STAGE 2: Host the App using Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
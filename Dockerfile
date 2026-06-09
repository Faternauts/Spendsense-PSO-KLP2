# Tahap 1: Mengompilasi Kode Flutter ke Versi Web
FROM debian:stable-slim AS build-env

# Memasang peralatan dasar Linux yang dibutuhkan Flutter
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa


# Mengunduh SDK Flutter resmi dari GitHub
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="${PATH}:/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin"

# Mengatur channel ke versi stabil dan memperbaruinya
RUN flutter channel stable
RUN flutter upgrade

# Menentukan folder kerja di dalam kontainer
WORKDIR /app

# Menyalin seluruh kode sumber Spendsense dari laptop ke dalam kontainer
COPY . .

# Mengunduh paket pustaka yang tertulis di pubspec.yaml
RUN flutter pub get

# Membangun aset web statis rilis (hasilnya akan ada di folder /build/web)
RUN flutter build web --release

# Tahap 2: Menjalankan Aset Web Menggunakan Web Server Nginx
FROM nginx:alpine

# Menyalin hasil kompilasi web dari Tahap 1 ke folder distribusi Nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Membuka gerbang jalur port 80
EXPOSE 80

# Menjalankan server Nginx secara permanen
CMD ["nginx", "-g", "daemon off;"]
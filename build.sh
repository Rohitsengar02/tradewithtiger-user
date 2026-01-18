#!/bin/bash

echo "Installing Flutter..."
if [ -d .flutter ]; then
  cd .flutter && git pull && cd ..
else
  git clone https://github.com/flutter/flutter.git -b stable .flutter
fi

export PATH="$PATH:`pwd`/.flutter/bin"

echo "Flutter Doctor..."
flutter doctor

echo "Creating .env file..."
# Create a .env file from Vercel Environment Variables to satisfy asset requirements
if [ ! -f .env ]; then
  touch .env
  echo "FIREBASE_API_KEY=$FIREBASE_API_KEY" >> .env
  echo "FIREBASE_APP_ID=$FIREBASE_APP_ID" >> .env
  echo "FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID" >> .env
  echo "FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID" >> .env
  echo "FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET" >> .env
  echo "FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN" >> .env
  echo "FIREBASE_MEASUREMENT_ID=$FIREBASE_MEASUREMENT_ID" >> .env
fi

echo "Enabling Web..."
flutter config --enable-web

echo "Get Dependencies..."
flutter pub get

echo "Building..."
flutter build web --release --no-tree-shake-icons --web-renderer auto

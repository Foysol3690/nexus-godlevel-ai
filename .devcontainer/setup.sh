#!/bin/bash
set -e
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev mesa-utils
if [ ! -d /opt/flutter ]; then
  curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.35.5-stable.tar.xz -o /tmp/flutter.tar.xz
  sudo tar xf /tmp/flutter.tar.xz -C /opt
  sudo chown -R codespace:codespace /opt/flutter
fi
export PATH="$PATH:/opt/flutter/bin"
if [ ! -d $HOME/android-sdk/cmdline-tools ]; then
  mkdir -p ~/android-sdk/cmdline-tools
  curl -LO https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip -o /tmp/cmdtools.zip
  unzip -q /tmp/cmdtools.zip -d ~/android-sdk/cmdline-tools
  mv ~/android-sdk/cmdline-tools/cmdline-tools ~/android-sdk/cmdline-tools/latest
fi
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools
flutter config --android-sdk $ANDROID_HOME
yes | sdkmanager --licenses || true
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
# Chrome for web
if ! command -v google-chrome-stable >/dev/null 2>&1; then
  wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get update && sudo apt-get install -y google-chrome-stable
fi
flutter doctor

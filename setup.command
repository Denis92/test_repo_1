#!/usr/bin/env bash

# найдем директорию, в которой лежит файл исполняемого срипта
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# перейдем в нее
cd "$DIR"

# установка Bundler, если необходимо
if hash bundler 2>/dev/null; 
then
    echo Bundler is installed
else    
    sudo gem install bundler
fi

# установка HomeBrew, если необходимо
if hash brew 2>/dev/null; 
then
    echo HomeBrew is installed
else    
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# установка xcodegen, если необходимо
if hash xcodegen 2>/dev/null; 
then
    echo xcodegen is installed
else    
    brew install xcodegen
fi

# Устанавливаем ruby зависимости.
# Cocoapods and Fastlane
bundle install

# создаем generated файлы
function mkdir_touch {
  mkdir -p "$(dirname "$1")"
  command touch "$1"
}

mkdir_touch Resources/R.generated.swift

# генерируем проект
sh xcodegen.command

# Обновляем репозиторий
bundle exec pod repo update

# Запускаем установку подов.
bundle exec pod install

# обновление сертификатов и профайлов development
bundle exec fastlane dev_cert_update

# обновление сертификатов и профайлов ad-hoc
bundle exec fastlane adhoc_cert_update
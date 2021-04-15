# найдем директорию, в которой лежит файл исполняемого скрипта
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 

# перейдем в нее
cd "$DIR"

# Проверка установки Bundler
if hash bundler 2>/dev/null; 
then
    echo Bundler is installed
else    
    echo Bundler is not installed, run bundle install
    exit 1
fi

# обновление сертификатов и профайлов development
bundle exec fastlane dev_cert_update

# обновление сертификатов и профайлов ad-hoc
bundle exec fastlane adhoc_cert_update
#!/bin/bash

case "$1" in
  "build")

  # NodeJS Kurulumunu yapalım.
  sudo apt-get install -y nodejs
  
  NODE_MAJOR=18

  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

  # PHP reposunu ekleyelim
  echo "PHP reposu ekleniyor..."
  sudo apt install software-properties-common
  sudo add-apt-repository ppa:ondrej/php
  php_repo_status=$?
  if [ $php_repo_status -eq 0 ]; then
     echo "PHP reposu başarıyla eklendi."
  else
     echo "HATA: PHP reposu eklenirken bir sorun oluştu."
     exit 1
  fi

  # PostgreSQL reposunu ekleyelim
  echo "PostgreSQL reposu ekleniyor..."
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > pgsql.gpg
  sudo mv pgsql.gpg /etc/apt/trusted.gpg.d/pgsql.gpg
  postgres_repo_status=$?
  if [ $postgres_repo_status -eq 0 ]; then
      echo "PostgreSQL reposu başarıyla eklendi."
  else
      echo "HATA: PostgreSQL reposu eklenirken bir sorun oluştu."
      exit 1
  fi

  # Debian kurulumu yapalım.
  echo "Debian kurulumuyla birlikte Liman MYS 2.0  yükleniyor..." 
  sudo apt update
  wget https://github.com/limanmys/core/releases/download/release.feature-new-ui.863/liman-2.0-RC2-863.deb
  sudo apt install ./liman-2.0-RC2-863.deb
  debian_status=$?
  if [ $debian_status -eq 0 ]; then
       echo "Debian başarıyla kuruldu. Liman MYS 2.0 hazır."
       sudo limanctl administrator
       echo "Daha önce giriş yaptıysanız veya eski bir sürümden güncellediyseniz"
       echo "ya da parolanızı kaybettiyseniz şu komutu kullanınız:"
       echo "sudo limanctl reset administrator@liman.dev"
  else
       echo "HATA: Debian kurulurken bir sorun oluştu."
       exit 1
  fi
    
    ;;

  "remove")
    # Liman MYS'yi kaldıralım
    echo "Liman MYS kaldırılıyor..."
    sudo apt-get remove liman
    sudo rm -rf /etc/liman
    sudo rm -rf /var/www/liman
    sudo apt-get autoremove	
    echo "Liman MYS başarıyla kaldırıldı."
    ;;

  "admin")
    # Liman MYS admin parolasını sıfırlayalım
    echo "Liman MYS admin parolası sıfırlanıyor..."
    sudo limanctl reset administrator@liman.dev
    echo "Admin parolası başarıyla sıfırlandı."
    ;;

  "reset")
    # Liman MYS kullanım bilgilerini gösterelim
    if [ -z "$2" ]; then
        echo "HATA: Eksik parametre! Kullanım: ./liman.sh reset <mail>"
        exit 1
    else
        echo "Liman MYS kullanım bilgileri sıfırlanıyor: $2"
        sudo limanctl reset "$2"
        echo "Kullanım bilgileri başarıyla sıfırlandı."
    fi
    ;;

  "help")
    # Liman MYS kullanım bilgilerini gösterelim
    echo "Liman MYS 2.0 Kurulum Scripti"
    echo "Kullanım:"
    echo "  ./liman.sh build : Liman MYS kurulumunu yapar"
    echo "  ./liman.sh remove : Liman MYS'yi kaldırır"
    echo "  ./liman.sh admin : sudo limanctl reset administrator@liman.dev"
    echo "  ./liman.sh reset <mail> : Liman MYS kullanım bilgilerini sıfırlar"
    echo "  ./liman.sh help : Liman MYS kullanım bilgilerini gösterir"
    ;;

  *)
    # Bilinmeyen komut durumunda genel yardım bilgilerini gösterelim
    echo "HATA: Bilinmeyen komut! Kullanım bilgilerini görmek için: ./liman.sh help"
    exit 1
    ;;
esac

exit 0

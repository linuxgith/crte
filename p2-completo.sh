#!/bin/bash

# Script com atualização dos navegadores, com instalação do av.sh e que funcione para PC com usuario

if [ "$1" = "" ]; then
   echo "faltou informar ip do colegio, tipo"
   echo -e "\e[33m bash $0  10.20.30.0/23  <inep>\e[0m "
   exit
fi

if [ "$2" = "" ]; then
   echo "sem inep informado, sem mudarmos hostname daeh"
   inep=''
   sleep 2
else
   inep="$2"
fi

# Testar se tem sshpass
if [ ! -x "/usr/bin/sshpass" ]; then
    echo -e "\e[41m FALTANDO PROGRAMA SSHPASS \e[0m, jah instalar fping tb"
    echo "por favor rodar comando:"
    echo "sudo apt-get  install -y sshpass fping"
    exit
fi
if [ ! -x "/usr/bin/fping" ]; then
    echo -e "\e[41m FALTANDO PROGRAMA fping \e[0m "
    echo "por favor rodar comando:"
    echo "sudo apt-get  install -y fping"
    exit
fi

SENHA0="@dmin*c@o"
SENHA1="Sc3l3p@r"
SENHA2="p3d@gogic0"

#echo -e "\e[44m Pra acessar máquinas lá dessa escola \e[0m "
#read -p " Qual senha do Administrador de lá? " -s SENHA
#echo "e"
#read -p " Qual senha do VNC dessa escola? " -s SENHA1
#echo "e"
#read -p " Qual senha do Pedagogico? " -s SENHA2
#echo ""

USUARIOS=( "administrador" "pedagogico" "admin" "admlocal" )
# Listas das senhas para tentativas
SENHAS=( "$SENHA0" "$SENHA1" "$SENHA2" )


export GREP_COLOR='0;31;42'

# Criando script.sh com outro nome no /tmp
script="/tmp/.script-rodar-cada-maquina.sh$$"
cat > "${script}" << EndOfThisFile
#!/bin/bash
export inep="$inep"
arqLog="/var/log/.log-run-p2.sh.log"
echo "Iniciando... "
if [ -e "\$arqLog" ]; then
    echo "No inep \$inep - Iniciada RE-execucao as \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLog"
else
    echo "No inep \$inep - Iniciando execucao em \$(date +%d/%m/%Y_%H:%M:%S_%N)" >> "\$arqLog"
fi
echo "copiando \$0 pra var/tmp" >> "\$arqLog"
cp "\$0" /var/tmp 2>> /dev/null
rodarEmNetVerde() {
    cd /tmp/
    if [ ! -e /opt/mstech/updatemanager.jar ]; then
        echo -e "\e[41m Netbook verde sem UpdateJava... tentar como um D3400\e[0m "
        atualizaNavegadoresAtomVscodeEtc
        tirarbloqueiodetela
        resetbackgrounds
        limparguests
        return
    fi

    if [ -e "/var/log/update_mint18_3_versao_07a.txt" ]; then
        echo "Jah TINHA V0.7a do chrome.sh uhuuu ebaaa"
    else
        echo -e "\e[43m  + + + Ativado pra rodar o Update V0.7a do chrome.sh neste aqui em background \e[0m "
        rm /tmp/.chromeinstalador.sh 2>> /dev/null
        for pid in \$(ps -ef | grep ".chromeinstalador.sh" | grep -v grep | awk '{print \$2}'); do kill -9 \$pid; done
        echo "wget -c www.labmovel.seed.pr.gov.br/Updates/chrome102-firefox102-mais-correcoes-paramint183_2022-07-11_09-17-28.sh" >> /tmp/.chromeinstalador.sh
        echo "bash chrome102-firefox102-mais-correcoes-paramint183_2022-07-11_09-17-28.sh" >> /tmp/.chromeinstalador.sh
        bash /tmp/.chromeinstalador.sh < /dev/null &> /dev/null & disown
    fi

    if [ -e "/usr/bin/atom" ]; then
        echo "Jah TINHA ATOM ebaa"
    else
        echo "Nao tinha ATOM, instalando em background ..."
        rm /tmp/.atominstalador.sh 2>> /dev/null
        for pid in \$(ps -ef | grep ".atominstalador.sh" | grep -v grep | awk '{print \$2}'); do kill -9 \$pid; done
        echo "wget -c www.labmovel.seed.pr.gov.br/Updates/atom-paramint183_2022-06-20_10-48-49.sh" >> /tmp/.instaladoratom.sh
        echo "bash atom-paramint183_2022-06-20_10-48-49.sh" >> /tmp/.instaladoratom.sh
        bash /tmp/.instaladoratom.sh < /dev/null &> /dev/null & disown
    fi

    if [ -e "/usr/share/code/code" ]; then
        echo "Jah Tinha VsCode ebaaa"
    else
        echo "Nao tinha VsCode, instalando em background ..."
        rm /tmp/.vscodeinstalador.sh 2>> /dev/null
        for pid in \$(ps -ef | grep ".vscodeinstalador.sh" | grep -v grep | awk '{print \$2}'); do kill -9 \$pid; done
        echo "wget -c www.labmovel.seed.pr.gov.br/Updates/vscode159-paramint183_2022-06-13_10-40-25.sh" >> /tmp/.vscodeinstalador.sh
        echo "bash vscode159-paramint183_2022-06-13_10-40-25.sh" >> /tmp/.vscodeinstalador.sh
        bash /tmp/.vscodeinstalador.sh < /dev/null &> /dev/null & disown
    fi
   
}

atualizaNavegadoresAtomVscodeEtc() {
    cd /tmp
    # Atualizar navegadores em background e trocar fundo de tela
    script="/tmp/.rodar-em-background$$"
    cat > "\${script}" << FimDoScriptBg
      #!/bin/bash
      cd /tmp
      wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
      rm repositorios.deb 2>> /dev/null
      wget http://ubuntu.celepar.parana/repositorios.deb
      if [ -e repositorios.deb ]; then
          dpkg -i repositorios.deb
      fi
      apt-get  update
      apt-get -y install firefox firefox-locale-pt google-chrome-stable
      rm pi1.sh 2>> /dev/null
      wget  jonilso.com/pi1.sh
      bash pi1.sh
      rm confmozilla.tar.gz 2>> /dev/null
      wget  jonilso.com/confmozilla.tar.gz
      cd /etc/skel
      mv .mozilla /tmp/.antigo-mozilla$$
      tar -xzf /tmp/confmozilla.tar.gz
      echo "Usuario convidado com novas configs do FIREFOX"


      if [ -e /home/escola ]; then
         echo "Fazendo Chrome Anonimo pra user Escola"
         updatedb
         locate -i "/home/escola/*google-chrome*desktop" | while read arquivo; do
             sed -i -e 's# --incognito##' "\\\$arquivo"
             sed -i -e 's#^Exec.*#& --incognito#' "\\\$arquivo"
         done

         usuario=escola
         if [ ! -e "/home/\\\${usuario}/.config/xfce4/panel" ]; then
             continue
         fi
         #echo "Alterando arquivo pasta /home/\\\${usuario}/.config/xfce4/panel"
         sed -i -e 's# --incognito##g' /home/\\\${usuario}/.config/xfce4/panel/launcher*/*
         find "/home/\\\${usuario}/.config/xfce4/panel" -type f -iname "*desktop" | while read arquivo; do
             if [ "\\\$(grep -i 'google-chrome' "\\\$arquivo" | wc -l)" -gt 0 ]; then
                sed -i -e 's#^Exec.*#& --incognito#' "\\\$arquivo"
             fi
         done
      fi

      if [ ! -e "/usr/bin/atom" ] || [ ! -e "/usr/share/code/code" ]; then
          wget  jonilso.com/av.sh
          bash av.sh
      else
         echo "jah tinha atom e vscode"
      fi
FimDoScriptBg
      bash "\${script}" < /dev/null &> /dev/null & disown
      echo "Rodando script em background"
}

tirarbloqueiodetela() {
   if [ -e "tb.sh" ]; then
       rm tb.sh
   fi
   if [ "\$(dpkg -l | grep xfce4-power-manager[^a-zA-Z-] | tail -1 | cut -c1-2)" = 'ii' ]; then
      wget  jonilso.com/tb.sh
      echo "Tirando bloqueio de tela rodando em background"
      bash  tb.sh < /dev/null &> /dev/null & disown
   else
      echo "jah configurado tirar bloqueio de tela"
   fi
}

resetbackgrounds() {
    if [ -e "rb.sh" ]; then
        rm rb.sh
    fi

    if [ -e "/usr/local/bin/restaurefundotela.sh" ]; then
        echo "jah com rb.sh no /usr/local/bin/restaurefundotela.sh "
    else
        echo "instalando reset de fundo de tela"
        wget jonilso.com/rb.sh
        bash rb.sh
    fi

}

limparguests() {
    if [ -e "lg.sh" ]; then
        rm lg.sh
    fi

    if [ -e "/usr/sbin/apagar-guest-ao-iniciar.sh" ]; then
        echo "jah com lg.sh nele"
    else
        echo "instalando limpar guests"
        wget jonilso.com/lg.sh
        bash lg.sh
    fi

}

ativartrocafundodetela(){
  cd /tmp
    if [ -e atf1.sh ]; then
        #rm atf1.sh
        echo "Jah tinha atf1.sh no temp"
    else
        wget jonilso.com/atf1.sh
        bash  atf1.sh
    fi
}
atalhopaginainicia(){
    cd /tmp
    if [ -e atalhopaginainicia.sh ]; then
        #rm atalhopaginainicia.sh
        echo "Jah tinha atalhopaginainicia.sh no temp"
    else
        wget jonilso.com/atalhopaginainicia.sh
        bash  atalhopaginainicia.sh
    fi
}

instalascratch(){
    cd /tmp
    if [ -e s.sh ]; then
        #rm s.sh
        echo "Jah tinha s.sh no temp"
    else
        wget -q jonilso.com/s.sh
        bash  s.sh
    fi
}

bloquearaplicativos(){
# Desativar acesso aos usuarios nos aplicativos a seguir:
    USUARIOSAPPS=( "professor" "escola" "Aluno" "aluno" "alunos" )
    APLICATIVOS=( "/usr/bin/users-admin" "/usr/bin/mugshot" "/usr/bin/mate-about-me" )

    for USUARIOCOMUN in "\${USUARIOSAPPS[@]}" ; do
        if [ \$(grep "^\${USUARIOCOMUN}:" /etc/passwd | wc -l) -eq 0 ]; then
            echo "Usuario \$USUARIOCOMUN nao consta neste Linux"
            continue
        fi  
            for APLICATIVO in "\${APLICATIVOS[@]}" ; do
        
            if [ -x "\$APLICATIVO" ]; then
                /bin/setfacl -m u:\${USUARIOCOMUN}:--- "\$APLICATIVO"
            fi  
       done
        echo "Aplicativos bloqueados para \$USUARIOCOMUN"
   done
  
}

PREFIXO='e'
TIPO=\$( dmidecode -t system | grep 'Product Name: ' | cut -d':' -f2 | sed -e s/'^ '// -e s/' '/'_'/g )
case "\$TIPO" in
  OptiPlex*)
    PREFIXO='d'
    echo -e "\e[44m DELLLL aquii \e[0m "
    cd /tmp/

    tirarbloqueiodetela
    ativartrocafundodetela
    resetbackgrounds
    limparguests
    atualizaNavegadoresAtomVscodeEtc
    instalascratch
    bloquearaplicativos

  ;;
  *C1300*)
    PREFIXO='t'
    echo ""
    echo -e "\e[43m ------ EDUCATRON ------ \e[0m  encontrado educatron aqui"
    atualizaNavegadoresAtomVscodeEtc
    tirarbloqueiodetela
    resetbackgrounds
    limparguests
    instalascratch
    bloquearaplicativos
  ;;  
  Positivo_Duo_ZE3630)
    PREFIXO='n'
    echo -e "\e[46mNetbook Verde Linux Mint \e[0m "
    rodarEmNetVerde
    atualizaNavegadoresAtomVscodeEtc
    tirarbloqueiodetela
    resetbackgrounds
    limparguests
    ativartrocafundodetela
    instalascratch
    bloquearaplicativos
  ;;
  N4340)
    PREFIXO='n'
    echo "Notebook Integral encontrado aqui"
    atualizaNavegadoresAtomVscodeEtc
    tirarbloqueiodetela
    resetbackgrounds
    limparguests
    ativartrocafundodetela
    instalascratch
    bloquearaplicativos
  ;;

  A14CR6A)
    PREFIXO='n'
    atualizaNavegadoresAtomVscodeEtc
    resetbackgrounds
    limparguests
    instalascratch
    bloquearaplicativos
  ;;
  *D610*)
    PREFIXO='e'
    echo "D610 encontrado aqui"
    atualizaNavegadoresAtomVscodeEtc
    limparguests
    bloquearaplicativos
  ;;

  D3400) 
    PREFIXO='e'
    echo -e "\e[46m Positivo D3400 \e[0m "
    echo "encontrado Positivo D3400 aqui"
    if [ ! -e "/usr/bin/atom" ] || [ ! -e "/usr/share/code/code" ]; then
        if [ ! -e "/usr/bin/atom" ] ; then
           echo "SEM ATOMM"
       else
           echo "SEM VSCODE"
        fi
    else
       echo "jah tinha atom e vscode ebaaa"
    fi
    atualizaNavegadoresAtomVscodeEtc
    cd /tmp
    if [ -e ah.sh ]; then
        #rm ah.sh
        echo "Jah tinha ah.sh no temp"
    else
        wget jonilso.com/ah.sh
        bash  ah.sh
    fi
    ativartrocafundodetela
    tirarbloqueiodetela
    resetbackgrounds
    limparguests
    date
    instalascratch
    bloquearaplicativos
  ;;

  POSITIVO_MASTER)
    PREFIXO='e'
    echo -e "\e[46m Positivo D3400 \e[0m "
    echo "encontrado Positivo D3400 aqui"
    if [ ! -e "/usr/bin/atom" ] || [ ! -e "/usr/share/code/code" ]; then
        if [ ! -e "/usr/bin/atom" ] ; then
           echo "SEM ATOMM"
       else
           echo "SEM VSCODE"
        fi
    else
       echo "jah tinha atom e vscode ebaaa"
    fi
    atualizaNavegadoresAtomVscodeEtc
    cd /tmp
    if [ -e ah.sh ]; then
        #rm ah.sh
        echo "Jah tinha ah.sh no temp"
    else
        wget jonilso.com/ah.sh
        bash  ah.sh
    fi
    ativartrocafundodetela
    tirarbloqueiodetela
    resetbackgrounds
    limparguests
    date
    instalascratch
    bloquearaplicativos
  ;;

  POS-EIB75CO)
    PREFIXO='e'
    atualizaNavegadoresAtomVscodeEtc
    bloquearaplicativos
    instalascratch
  ;;
    
  *)
      echo "Acesso Linux nao identificado ainda"
      echo "TIPO \$TIPO"

  ;;
esac

if [ -e "/usr/lib/firefox/defaults/pref/firefox.cfg" ]; then
    if [ "\$(grep -i prd /usr/lib/firefox/defaults/pref/firefox.cfg | wc -l)" -gt 0 ]; then
        echo -e "\e[106m Tirando proxy  ... \e[0m "
        wget  jonilso.com/tirar-proxy-mint.sh

        bash  tirar-proxy-mint.sh
    else
        echo -e "\e[44m Jah consta sem proxy firefox \e[0m "

    fi
else
   echo -e "FIREFOX sem proxy pois nem tem o arquivo /usr/lib/firefox/defaults/pref/firefox.cfg "
   lsb_release -a
fi

graveHostname() {
   if [ "$inep" = "" ]; then
     echo "Sem inep"
     return
   fi
   if [ \$(grep "\$inep" /etc/hostname | wc -l) -eq 1 ]; then
      echo "consta inep no hostname jah ebaaa"
      return
   fi
   hostName=\$(hostname) # txxxx-abcdef
   export hostnameCorreto="\${PREFIXO}\${inep}-\$fimMac"
   echo "Hostname correto pra Equipamento eh '\$hostnameCorreto'"
   if [ \$(grep "\$hostnameCorreto" /etc/hostname | wc -l) -eq 0 ]; then
      echo "Hostname estava errado"
      echo "\$hostnameCorreto" > /etc/hostname
      sed -i "s/\$hostName/\$hostnameCorreto/" /etc/hosts
      hostnamectl set-hostname "\$hostnameCorreto"
      if [ \$(grep "\$hostnameCorreto" /etc/hosts | wc -l) -eq 0 ]; then
         echo "127.0.1.1 \$hostnameCorreto" >> /etc/hosts
      fi
      if [ -x /usr/bin/ocsinventory-agent ]; then
          echo "criando OCS em Nohup"
          cat > "/tmp/.nohupdoocs.sh" << EndOfThisFileIsExactHereNowReally
#!/bin/bash
#\$0 < /dev/null &> /dev/null & disown
case "\$1" in
    -d|--daemon)
        /tmp/.nohupdoocs.sh < /dev/null &> /dev/null & disown
        echo "chamando novamente \$(date)" >> /var/tmp/nohupdoocs-baixando.txt
        exit 0
        ;;
    *)
        ;;
esac
cd /tmp/
echo "em 1 temos \$1 em \$(date)" >> /var/tmp/nohupdoocs-baixando.txt
temDownloadAgindo=\$(ps aux | grep nohupdoocs | grep '.nohupdoocs.sh' | grep -v grep | wc -l)
if [ \$temDownloadAgindo -gt 0 ]; then
    echo "Ja tem nohupdoocs executando \$(date)" >> /var/tmp/nohupdoocs-baixando.txt
else
    echo "Agora nohupdoocs executando \$(date)" >> /var/tmp/nohupdoocs-baixando.txt
    /usr/bin/ocsinventory-agent &
fi
EndOfThisFileIsExactHereNowReally
           chmod +x /tmp/.nohupdoocs.sh
           nohup bash /tmp/.nohupdoocs.sh -d >> /dev/null 2>&1
           echo "add OCS NoHUPP; "
      fi
   else
      echo "hostname estah correto"
   fi
}



if [ "$inep" = "" ]; then
    echo "Sem mudar hostname pq nao sabemos inep"
else
    # Mudar hostname se nao constar INEP
    ipLinks=\$(ip link show | grep ^[0-9] | cut -d':' -f2 | sed 's/ //g')
    for i in \$ipLinks; do
       if [[ "\$i" = "lo" ]]; then
          continue
       fi

       if [ "\$fimMac" = "" ]; then
          mac=\$(ifconfig "\$i" | grep -i ether | sed 's/^ *ether *//' | cut -d ' ' -f1 |sed 's/:/-/g'|sed 's/ //g')
          if [ \${#mac} -gt 17 ] || [ \${#mac} -le 15 ] ; then
             mac=\$(ifconfig "\$i" 2>> /dev/null | grep 'ether '| sed 's/^[ \t]*ether //' | sed 's/ .*//' | sed 's/:/-/g'|sed 's/ //g')
          fi

          echo "MAC eh [\$mac]"
          fimMac=\$(echo \$mac | sed 's/-//g' | sed 's/[^a-fA-F0-9]//g' | cut -c7- )
       fi
    done
    if [ "\$fimMac" = "" ]; then
       echo "script falhou ao pegar mac :( "
    else
       graveHostname
    fi
fi

if [ -e "/usr/sbin/apagar-guest-ao-iniciar.sh" ]; then
    echo "jah com lg.sh nele"
else
    wget jonilso.com/lg.sh
    bash lg.sh
fi

if [ -e "/etc/xdg/autostart/ca-filtrowebseed.desktop" ]; then
   echo -e "\e[42m +++ Certificado ok ++++ \e[0m"
else
   wget -c  jonilso.com/cert.sh
   echo -e "\e[43m Instalando Certificado em background .... \e[0m"
   bash  cert.sh < /dev/null &> /dev/null & disown

fi

if [ -e /home/escola ]; then
   echo "Fazendo Chrome Anonimo pra user Escola"
   updatedb
   locate -i "/home/escola/*google-chrome*desktop" | while read arquivo; do
       sed -i -e 's# --incognito##' "\$arquivo"
       sed -i -e 's#^Exec.*#& --incognito#' "\$arquivo"
   done

   usuario=escola
   if [ ! -e "/home/\${usuario}/.config/xfce4/panel" ]; then
       continue
   fi
   #echo "Alterando arquivo pasta /home/\${usuario}/.config/xfce4/panel"
   sed -i -e 's# --incognito##g' /home/\${usuario}/.config/xfce4/panel/launcher*/*
   find "/home/\${usuario}/.config/xfce4/panel" -type f -iname "*desktop" | while read arquivo; do
       if [ "\$(grep -i 'google-chrome' "\$arquivo" | wc -l)" -gt 0 ]; then
          sed -i -e 's#^Exec.*#& --incognito#' "\$arquivo"
       fi
   done
fi


if [ -e "/opt/google/chrome/google-chrome" ]; then
    echo "chrome indo pra nova pg inicial de fabrica"
    sed -i 's# www.google.com.*\$# https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
    sed -i 's# www.gmail.com.*\$# https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
    sed -i 's#^ *exec -a "\\\$0" "\\\$HERE/chrome" "\\\$@"\\\$#& https://www.educacao.pr.gov.br/iniciar#' /opt/google/chrome/google-chrome
else
    echo "sem chrome"
fi

echo -n "em firefox com nova pagina inicial tb - "
if [ -e "/usr/bin/firefox" ]; then
   sed -i 's# www.educacao.pr.gov.br/iniciar##g' /usr/bin/firefox
   sed -i 's#^[ \t]*exec.*#& www.educacao.pr.gov.br/iniciar#g' /usr/bin/firefox
fi
if [ -e "/usr/lib/firefox/defaults/pref/firefox.cfg" ]; then
    sed -i '/browser.startup.homepage/d' /usr/lib/firefox/defaults/pref/firefox.cfg 2>> /dev/null
    echo "pref(\"browser.startup.homepage\",\"https://www.educacao.pr.gov.br/iniciar\");" >> /usr/lib/firefox/defaults/pref/firefox.cfg
    echo "ok"
else
    echo "! sem arquivo .cfg"
fi
if [ -f "/home/framework/Área de Trabalho/libreoffice7.0-calc.desktop" ]; then
    sed -i -e 's/=Exel$/=Excel/' "/home/framework/Área de Trabalho/libreoffice7.0-calc.desktop"
fi



# configurar pagina inicial do firefox para essa tambem em config user
cd /home
for usuario in *; do
   if [[ "\$usuario" = *"lost"* ]]; then
       #echo "Pasta lost+found nem mexeremos"
       continue
   fi
   if [ ! -e "/home/\${usuario}/.mozilla/firefox/" ]; then
       continue
   fi
   #echo "Alterando arquivo pasta /home/\${usuario}/.mozilla/firefox"
   cd "/home/\${usuario}/.mozilla/firefox"
   for diretorio in *; do
       if [ ! -e "\${diretorio}/prefs.js" ]; then
           continue
       fi
       #echo "removendo do /home/\${usuario}/.mozilla/firefox/\${diretorio}/prefs.js"
       sed -i -e '/browser\.startup\.homepage/d' "/home/\${usuario}/.mozilla/firefox/\${diretorio}/prefs.js"
       if [ -e "/home/\${usuario}/.mozilla/firefox/\${diretorio}/user.js" ]; then
           sed -i -e '/browser\.startup\.homepage/d' "/home/\${usuario}/.mozilla/firefox/\${diretorio}/user.js"
       fi
       echo 'user_pref("browser.startup.homepage", "www.educacao.pr.gov.br/iniciar");' >> "/home/\${usuario}/.mozilla/firefox/\${diretorio}/prefs.js"
       echo 'user_pref("browser.startup.homepage", "www.educacao.pr.gov.br/iniciar");' >> "/home/\${usuario}/.mozilla/firefox/\${diretorio}/user.js"
   done
done

if [ -e /etc/systemd/timesyncd.conf ]; then
   sed -i 's;^#NTP=;NTP=200.189.114.130;' /etc/systemd/timesyncd.conf
   sed -i '/NTP=172.16.0.1/d' /etc/systemd/timesyncd.conf
   sed -i '/NTP=200.189.114.131/d' /etc/systemd/timesyncd.conf
   sed -i '/NTP=200.186.125.195/d' /etc/systemd/timesyncd.conf
   sed -i '/NTP=200.189.40.8/d' /etc/systemd/timesyncd.conf
   sed -i 's/NTP=200.189.114.130/NTP=200.189.114.130\nNTP=200.189.114.131\nNTP=200.186.125.195\nNTP=200.189.40.8/' /etc/systemd/timesyncd.conf

   timedatectl set-local-rtc 0
   #timedatectl set-ntp 1
   systemctl stop systemd-timesyncd >> /dev/null 2>&1
   systemctl start systemd-timesyncd >> /dev/null 2>&1
   systemctl daemon-reload
   echo "alterado no systemd no timesyncd.conf"
   date
fi
EndOfThisFile

# LISTA DE IPS DIRETOS DE NETS
echo "..."
echo "Buscando ips ..."
fping -a -g "$1" 2>> /dev/null | tee "/tmp/.lista-ips-nets-escola-especifica$$.txt"
filename="/tmp/.lista-ips-nets-escola-especifica$$.txt"

SSHCONF="/tmp/sshconfigtmppp$$"
/bin/cat <<EOF >$SSHCONF
Host *
   ServerAliveInterval 240
   ServerAliveCountMax 2
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

qtos=0
c=0
qtDel=0
qtNet=0
qtNotIntegral=0
qtDdd=0
qtEduc=0
qtD3400=0
qtOutros=0
while read dados; do
{
    # SEM MACS ESTA LISTA
    #mac=$(echo $dados| cut -d';' -f1)
    if [[ "$dados" = "" ]]; then
        continue
    fi
    ip=$(echo $dados| cut -d';' -f1)
    #ip=$(echo $dados| cut -d';' -f2)
    #ip=$(echo $dados| cut -f2)
    echo "olhando ip $ip "
    ((qtos=$qtos+1))

    # ACESSO A CADA NETBOOK DAI

    ping -c1 -w3 -q $ip >> /dev/null
    if [ $? -eq 0 ]; then
        nc -z -w3 "$ip" 22
        if [ $? -eq 0 ]; then
            echo "PING OK e tem SSH"
            {
               export AcessoOk=0

               echo "" > /tmp/.resultado.txt.$$
               for USUARIO in "${USUARIOS[@]}" ; do
                   ctPass=0
                   for SENHA in "${SENHAS[@]}" ; do
                       ((ctPass=$ctPass+1))

                       sshpass -p "$SENHA" scp -o StrictHostKeyChecking=no "$script" ${USUARIO}@$ip:/tmp/.scriptkx.sh 2>> /dev/null
                       if [ $? -eq 0 ]; then
                           echo -e "\e[46mLinux acessou com usuario $USUARIO ao ip $ip, vamos lahhh  \e[0m "
                           sshpass -p "$SENHA" ssh -F $SSHCONF -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t ${USUARIO}@$ip "echo \"PC \$(hostname) vivo ha \$(uptime)\"; echo $SENHA | sudo -S bash /tmp/.scriptkx.sh" | tee "/tmp/.resultado.txt.$$"
                           export AcessoOk=1
                           break
                       else
                           echo "falhou acesso com usuario $USUARIO e senha $ctPass ... vamos tentar com outro(a) ..."
                       fi

                   done
                   if [ "$(grep "DELLLL aquii" "/tmp/.resultado.txt.$$" | wc -l)" -gt 0 ]; then
                      export qtDel=$((qtDel+1))
                   elif [ "$(grep "Netbook Verde Linux Mint" "/tmp/.resultado.txt.$$" | wc -l)" -gt 0 ]; then
                      export qtNet=$((qtNet+1))
                   elif [ "$(grep "Notebook Integral" "/tmp/.resultado.txt.$$" | wc -l)" -gt 0 ]; then
                      export qtNotIntegral=$((qtNotIntegral+1))
                   elif [ "$(grep "D610 encontrado aqui" "/tmp/.resultado.txt.$$" | wc -l)" -gt 0 ]; then
                      export qtDdd=$((qtDdd+1))
                   elif [ "$(grep "encontrado educatron aqui" "/tmp/.resultado.txt.$$" | wc -l)" -gt 0 ]; then
                      export qtEduc=$((qtEduc+1))
                   elif [ "$(grep "encontrado Positivo D3400 aqui" "/tmp/.resultado.txt.$$" | wc -l)" -gt 0 ]; then
                      export qtD3400=$((qtD3400+1))
                   elif [ "$(grep "Acesso Linux nao identificado ainda" "/tmp/.resultado.txt.$$" | wc -l)" -gt 0 ]; then
                      export qtOutros=$((qtOutros+1))
                   fi

                   if [ $AcessoOk -eq 1 ]; then break; fi

               done

           }
       else
           echo "SEM SSH no ip $ip "
       fi
    else
     echo "sem resposta $ip"
    fi

    echo "  --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ------ --- --- ---"

} < /dev/null
done < $filename


echo -e "\e[43m   ++++   RELATÓRIO   ++++   \e[0m "
echo "Acessados $qtDel ips de computadores Dell"
echo "Acessados $qtNet ips de Netbook verde"
echo "Acessados $qtNotIntegral ips de Notebook Integral"
echo "Acessados $qtDdd ips de computadores D610"
echo "Acessados $qtEduc ips de Educatrons"
echo "Acessados $qtD3400 ips de Positivo D3400"
echo "Acessados $qtOutros ips de outros Linux"
echo -e "\e[43m   ++++   +++++++++   ++++   \e[0m "
echo ""


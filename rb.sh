#!/bin/bash
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"

if [ "$(whoami)" != "root" ] ; then
   echo " !! Precisa executar como super-usuario !! Por favor executar como super-usuario."
   exit
fi

if [ ! -e "/etc/linuxmint/info" ]; then
    echo "Esta maquina num eh Mint! Num sei daeh! Saindo por garantia he he he!"
    exit 1
fi

if [ -e '/media/dados/logs/' ]; then
    arqLogDisto="/media/dados/logs/.log-script-restaurar-fundo-tela.log"
else
    arqLogDisto="/var/log/.log-script-restaurar-fundo-tela.log"
fi
echo "iniciando. "
echo "Iniciando em $(date)" >> "$arqLogDisto"

export ipLink=''
ipLinks=$(ip link show | grep ^[0-9] | cut -d':' -f2 | sed 's/ //g')
for i in $ipLinks; do
   if [[ "$i" = "lo" ]]; then continue; fi
   iniciais=$(echo $i | cut -c1-3)
   if [[ "$iniciais" = "enp" ]]; then
      export ipLink=$i
   fi
   if [[ "$iniciais" = "wlp" ]]; then
      export ipWifiLink=$i
   fi
done
if [[ "$ipLink" = '' ]]; then
   ipLink='enp2s0'
fi
if [[ "$ipWifiLink" = '' ]]; then
   ipWifiLink='wlp3s0'
fi

ipLan=$(ifconfig "$ipLink" 2>> /dev/null | grep 'inet end.'| cut -d':' -f2 | sed 's/Bcast//' | sed 's/ //g')
if [[ "$ipLan" = "" ]]; then
   ipLan=$(ifconfig "$ipLink" 2>> /dev/null | grep 'inet addr:'| cut -d':' -f2 | sed 's/Bcast//' | sed 's/ //g')
fi
if [[ "$ipLan" = "" ]]; then
   ipLan=$(ifconfig "$ipLink" 2>> /dev/null | grep 'inet ' | sed 's/^[ \t]*inet  *//'| cut -d' ' -f1 | sed 's/Bcast//' | sed 's/ //g')
fi
ipWifi=$(ifconfig "$ipWifiLink" 2>> /dev/null | grep 'inet end.'| cut -d':' -f2 | sed 's/Bcast//'| sed 's/ //g')
if [[ "$ipWifi" = "" ]]; then
   ipWifi=$(ifconfig "$ipWifiLink" 2>> /dev/null | grep 'inet addr:'| cut -d':' -f2 | sed 's/Bcast//'| sed 's/ //g')
fi
if [[ "$ipWifi" = "" ]]; then
   ipWifi=$(ifconfig "$ipWifiLink" 2>> /dev/null | grep 'inet ' | sed 's/^[ \t]*inet  *//'| cut -d' ' -f1 | sed 's/Bcast//' | sed 's/ //g')
fi
mac=$(ifconfig $ipLink 2>> /dev/null |sed 's/^enp.*HW //;q'|sed 's/^enp.*HWaddr //;q'|sed 's/:/-/g'|sed 's/ //g')
if [ ${#mac} -gt 17 ] || [ ${#mac} -le 15 ] ; then
    mac=$(ifconfig $ipLink 2>> /dev/null | grep 'Link encap:Ethernet' | sed 's/^.* de HW //' | sed 's/:/-/g'| sed 's/ //g')
fi
if [ ${#mac} -gt 17 ] || [ ${#mac} -le 15 ] ; then
   mac=$(ifconfig "$ipLink" 2>> /dev/null | grep -i ether | sed 's/^ *ether *//' | cut -d ' ' -f1 |sed 's/:/-/g'|sed 's/ //g')
fi
serialNet=$(dmidecode | grep -A9 'System Information' | grep 'Serial Number'| sed 's/.*: //')
hostName=$(hostname)
if [ "$serialNet" = "0" ] || [ "$serialNet" = "" ]; then
    serialNet="NaoDetectado"
fi

echo "Hostname [$hostName] wifi [$ipWifi] Lan[$ipLan] serial[$serialNet] mac[$mac]"
echo ""

# Scripts

cat > "/usr/local/bin/restaurefundotela.sh" << EndOfThisFileIsExactHere
#!/bin/bash
if [ -e '/usr/share/xfce4/backdrops/0-parana-integral.jpg' ]; then
    FUNDOTELA="/usr/share/xfce4/backdrops/0-parana-integral.jpg"
elif [ -e "/usr/share/xfce4/backdrops/linuxmint.jpg" ]; then
    FUNDOTELA="/usr/share/xfce4/backdrops/linuxmint.jpg"
elif [ -e "/usr/share/xfce4/backdrops/linuxmint.png" ]; then
    FUNDOTELA="/usr/share/xfce4/backdrops/linuxmint.png"
else
    FUNDOTELA="/usr/share/backgrounds/linuxmint/linuxmint.jpg"
fi
if [ -e "/usr/bin/xfce4-session" ]; then
   xfconf-query -c xfce4-desktop -lv | while read param; do
   {
       lastImage=\$(echo "\$param" | grep "last-image" | sed 's/[ \t].*//') 
       backdropCycle=\$(echo "\$param" | grep "backdrop-cycle-enable" | sed 's/[ \t].*//')
       if [ "\$lastImage" = "" ] && [ "\$backdropCycle" = "" ]; then
           continue;
       fi

       if [ "\$backdropCycle" != "" ]; then
           #echo "desativado Cycle"
           xfconf-query -c xfce4-desktop -p "\$backdropCycle" -r -R
       fi

       if [ "\$lastImage" != "" ]; then
           #echo "mudando fundo tela ao padrao"
           xfconf-query -c xfce4-desktop -p "\$lastImage" -s "\$FUNDOTELA"
       fi
   }
   done
else
   gsettings set org.cinnamon.desktop.background picture-uri "file://\$FUNDOTELA"
fi
#echo fim
EndOfThisFileIsExactHere
chmod +x /usr/local/bin/restaurefundotela.sh

cat > "/usr/local/bin/restauretelalogout.sh" << EndOfThisFileIsExactHere
#!/bin/bash
/usr/local/bin/restaurefundotela.sh
#echo fim
EndOfThisFileIsExactHere
chmod +x "/usr/local/bin/restauretelalogout.sh"

cat > "/usr/local/bin/restauretelalogin.sh" << EndOfThisFileIsExactHere
#!/bin/bash
while true; do
    /usr/local/bin/restaurefundotela.sh
    sleep 500
done
#echo fim
EndOfThisFileIsExactHere
chmod +x /usr/local/bin/restauretelalogin.sh


cat > "/etc/xdg/autostart/restaurar-fundo-tela-ao-deslogar.desktop" << EndOfThisFileIsExactHere
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=Restaurar fundo tela ao Deslogar
Comment=Restaurar fundo tela ao Deslogar
Exec=/usr/local/bin/restauretelalogout.sh
RunHook=1
StartupNotify=false
Terminal=false
Hidden=true
EndOfThisFileIsExactHere
chmod +x /etc/xdg/autostart/restaurar-fundo-tela-ao-deslogar.desktop

cat > /etc/xdg/autostart/restaurar-fundo-tela.desktop << EndOfThisFileIsExactHereNowReally
[Desktop Entry]
Version=1.0
Type=Application
Name=RestaurarFundoTela
Comment=RestaurarFundoTela
Exec=/usr/local/bin/restauretelalogin.sh
Icon=preferences-system-sound
Path=
Terminal=false
StartupNotify=false
EndOfThisFileIsExactHereNowReally
chmod +x /etc/xdg/autostart/restaurar-fundo-tela.desktop


versaoMint=$(cat /etc/linuxmint/info | grep 'RELEASE=' | cut -d'=' -f2 | head -1)
if [ "$versaoMint" = "20.1" ] || [ "$versaoMint" = "20.2" ] || [ "$versaoMint" = "20.3" ] ; then
   cat > /etc/xdg/autostart/restaurar-fundo-tela.desktop << EndOfThisFileIsExactHereNowReally
[Desktop Entry]
Encoding=UTF-8
Name=RestaurarFundoTela
Comment=RestaurarFundoTela
Icon=preferences-system-sound
Exec=/usr/local/bin/restauretelalogin.sh
Terminal=false
Type=Application
Categories=
EndOfThisFileIsExactHereNowReally
   chmod +x /etc/xdg/autostart/restaurar-fundo-tela.desktop
fi

if [ -e "/var/lib/lightdm/.cache/slick-greeter/state" ]; then
    sed -i 's/last-user=.*/last-user=*guest/g' /var/lib/lightdm/.cache/slick-greeter/state
fi

if [ -e "/etc/lightdm/slick-greeter.conf" ]; then
    if [ "$(grep 'draw-user-backgrounds' "/etc/lightdm/slick-greeter.conf" | wc -l)" -gt 0 ]; then
        sed -i 's/draw-user-backgrounds=.*/draw-user-backgrounds=false/' /etc/lightdm/slick-greeter.conf
    else
        echo "draw-user-backgrounds=false" >> /etc/lightdm/slick-greeter.conf
    fi
else
    echo "[Greeter]" > /etc/lightdm/slick-greeter.conf
    echo "draw-user-backgrounds=false" >> /etc/lightdm/slick-greeter.conf
fi

# Se ninguem logado
logado=$(/usr/bin/w | grep '/sbin/upstart' | wc -l)
if [ $logado -eq 0 ]; then
    logado=$(/usr/bin/w | grep -v 'LOGIN@' | grep -v 'load average:' | awk '{print $3}' | grep ':[0-9]' | wc -l)
fi
if [ $logado -eq 0 ]; then
    logado=$(/usr/bin/w | grep 'xfce4-session' | wc -l)
fi
if [ $logado -eq 0 ]; then
   echo "vamos reiniciar o lighdm pra mostrar versao $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
   echo "Ninguem logado, entao reiniciar LightDM ..."
   /etc/init.d/lightdm restart >> /dev/null 2>&1&
   echo "resultado $? de reiniciar lighdm $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
   #/usr/bin/nohup /etc/init.d/lightdm restart >> "$arqLogDisto" 2>&1&

   # Se ninguem logado ver se LIGHTDM TRAVOU
   sleep 8
   travouLightdm=$(ps aux | grep lightdm | grep -v grep | wc -l)
   if [ $travouLightdm -eq 0 ]; then
      echo "lighdm travou, reboot em 1min"
      echo "travou o lighdm, reiniciando em 1min entao (ninguem logado) $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
      /sbin/shutdown -r +1 "Server will restart in 1 minute. Please save your work."
   else
      echo "ninguem logado e light nao travou $(date +%d/%m/%Y_%H:%M:%S_%N)" >> "$arqLogDisto"
      echo "lighdm ok;"
   fi

fi

if [ $logado -eq 0 ]; then
    echo "Criados auto-starts e scripts. Por favor testar"
else
    echo -e "Criados auto-starts e scripts. \e[43m Por favor deslogar \e[0m e daeh testar"
fi


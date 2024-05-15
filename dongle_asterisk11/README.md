# Instalação Chan_Dongle no Issabel 4

## Instalação de ferramentas.
```
# yum -y install tcl asterisk11-devel make automake binutils nano git
```

## Baixar e instalar drive
```
# cd /usr/src/dongle_asterisk11
# git clone --depth 1 --branch main --single-branch https://github.com/joandson19/Issabel_PBX.git dongle_asterisk11
# rpm -ivh usb_modeswitch-1.2.3-1.el6.rf.x86_64.rpm
# yum install usb_modeswitch -y
```

## Instalação do modulo
```
# aclocal && autoconf && automake -a
# ./configure
# make 
# make install
# cp chan_dongle.so /usr/lib64/asterisk/modules/
# cp etc/dongle.conf /etc/asterisk
```

## Permissões de acesso do asterisk a porta USB
```
# nano /etc/udev/rules.d/92-dongle.rules
KERNEL=="ttyUSB*", MODE="0666", OWNER="asterisk", GROUP="uucp"
```

## Ajustes
```
# nano /etc/asterisk/asterisk.conf
rungroup = dialout
```

## Reboot no sistema operacional
```
# reboot
```

# Tudo pronto!

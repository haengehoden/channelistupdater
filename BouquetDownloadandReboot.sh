#!/bin/sh

## configuration

URL="https://github.com/haengehoden/channelistupdater"
FILENAME="servicesE2_bc.tar.gz"
BQ="https://github.com/haengehoden/channelistupdater/picon.tar.gz"

## end

## leeren und aktualisieren der picons ##
cd /usr/share/enigma2/picon
#rm -rf /usr/share/enigma2/picon/
wget $BQ
tar -xzvf picon.tar.gz
sleep 5
rm picon.tar.gz

foo="$0"
shTXT=${foo%.*}".txt"

shFORCE=`echo $0| sed s?download?download\(forced\)?`

DirEnigma=/etc/enigma2/
E2conf="$DirEnigma"settings
fLAMEDB="$DirEnigma"lamedb
fTMP="$fLAMEDB".tmp

rm -rf /tmp/$FILENAME /tmp/"$FILENAME"_md5.txt "$fTMP" ""$shFORCE""

RemoveTerrestialBouquets () {
	sed -e 's/.*"userbouquet\.lattelecom\.tv".*//' -e 's/.*"userbouquet\.baltcom\.tv".*//' "$DirEnigma"bouquets.tv| sed '/^$/d'>"$DirEnigma"bouquets.tv.tmp
	[ -s "$DirEnigma"bouquets.tv.tmp ] && mv "$DirEnigma"bouquets.tv.tmp "$DirEnigma"bouquets.tv
	rm -f "$DirEnigma"*lattelecom.tv "$DirEnigma"*baltcom.tv
	#RebootBox=1
}

PatchTerrestialRegionalTransponders () {
	case `cat "$fLAMEDB"_patch_dvbt` in
	cesvaine)
		sed -e 's/t\ 530000000:/t\ 634000000:/' -e 's/t\ 554000000:/t\ 770000000:/' -e 's/t\ 650000000:/t\ 482000000:/' -e 's/t\ 666000000:/t\ 858000000:/' -e 's/t\ 690000000:/t\ 546000000:/' -e 's/t\ 658000000:/t\ 498000000:/' "$fLAMEDB">"$fTMP";;
	daugavpils)
		sed -e 's/t\ 530000000:/t\ 682000000:/' -e 's/t\ 554000000:/t\ 714000000:/' -e 's/t\ 650000000:/t\ 818000000:/' -e 's/t\ 666000000:/t\ 522000000:/' -e 's/t\ 690000000:/t\ 618000000:/' -e 's/t\ 658000000:/t\ 626000000:/' "$fLAMEDB">"$fTMP";;
	kuldiga)
		sed -e 's/t\ 530000000:/t\ 546000000:/' -e 's/t\ 554000000:/t\ 626000000:/' -e 's/t\ 650000000:/t\ 682000000:/' -e 's/t\ 666000000:/t\ 722000000:/' -e 's/t\ 690000000:/t\ 506000000:/' -e 's/t\ 658000000:/t\ 586000000:/' "$fLAMEDB">"$fTMP";;
	liepaja)
		sed -e 's/t\ 530000000:/t\ 474000000:/' -e 's/t\ 554000000:/t\ 794000000:/' -e 's/t\ 650000000:/t\ 802000000:/' -e 's/t\ 666000000:/t\ 514000000:/' -e 's/t\ 690000000:/t\ 570000000:/' -e 's/t\ 658000000:/t\ 586000000:/' "$fLAMEDB">"$fTMP";;
	rezekne)
		sed -e 's/t\ 530000000:/t\ 658000000:/' -e 's/t\ 554000000:/t\ 706000000:/' -e 's/t\ 650000000:/t\ 802000000:/' -e 's/t\ 666000000:/t\ 522000000:/' -e 's/t\ 690000000:/t\ 618000000:/' -e 's/t\ 658000000:/t\ 602000000:/' "$fLAMEDB">"$fTMP";;
	valmiera)
		sed -e 's/t\ 530000000:/t\ 474000000:/' -e 's/t\ 554000000:/t\ 714000000:/' -e 's/t\ 650000000:/t\ 738000000:/' -e 's/t\ 666000000:/t\ 706000000:/' -e 's/t\ 690000000:/t\ 570000000:/' -e 's/t\ 658000000:/t\ 826000000:/' "$fLAMEDB">"$fTMP";;
	viesite)
		sed -e 's/t\ 530000000:/t\ 610000000:/' -e 's/t\ 554000000:/t\ 674000000:/' -e 's/t\ 650000000:/t\ 786000000:/' -e 's/t\ 666000000:/t\ 730000000:/' -e 's/t\ 690000000:/t\ 514000000:/' -e 's/t\ 658000000:/t\ 490000000:/' "$fLAMEDB">"$fTMP";;
	esac
	[ -s "$fTMP" ] && mv "$fTMP" "$fLAMEDB"
}

CleanBouquetsFromNotInstalledSattelites () {
	FoundSatPosHEX="" SatPosToSED=""
	for SatPosHEX in `grep "#SERVICE 1:0:.*:.*:.*:.*:.*:0:0:0:" "$DirEnigma"userbouquet.*| sed -e s/....:0:0:0://g -e s/.*://g| sort| uniq`; do
		SatPosDEC=$((0x$SatPosHEX))
		if [ "$SatPosDEC" -le 3600 ]; then
		#	echo sat
			[ "$SatPosDEC" -gt 1800 ] && SatPosANA=$((((3600-SatPosDEC+2))/10))" West" || SatPosANA=$((((SatPosDEC+2))/10))" East"
			#if ! grep -qs ".sat.$SatPosDEC." "$E2conf"; then
				#echo "Sat pos "$SatPosANA" not installed - remove services from bouquet files"
				#[ ! "$SatPosToSED" ] && SatPosToSED="$SatPosHEX" || SatPosToSED="$SatPosToSED\\|$SatPosHEX"
			#else
				#echo "Sat pos "$SatPosANA" found - ok"
			#fi
			if grep -qs ".sat.$SatPosDEC." "$E2conf" || grep -qs ".diseqc[A-D]=$SatPosDEC" "$E2conf"; then
				echo "Sat pos "$SatPosANA" found - ok"
			else
				echo "Sat pos "$SatPosANA" not installed - remove services from bouquet files"
				[ ! "$SatPosToSED" ] && SatPosToSED="$SatPosHEX" || SatPosToSED="$SatPosToSED\\|$SatPosHEX"
			fi
		#elif [ "$SatPosDEC" = 56797 ]; then
		#	echo cable
		#elif [ "$SatPosDEC" = 61166 ]; then
		#	echo air
		fi
	done
	if [ "$SatPosToSED" ]; then
		for fBouquet in "$DirEnigma"userbouquet.*.tv "$DirEnigma"userbouquet.*.radio; do
			sed s/^"#SERVICE\ 1:0:.*:.*:.*:.*:\("$SatPosToSED"\)"....:.*:.*:.*://g "$fBouquet"| uniq| sed '/^$/{N;s/\n\#DESCR.*//;}'| sed '/^$/d'>"$fBouquet".tmp
			if [ -s "$fBouquet".tmp ] && [ `md5sum $fBouquet| awk {'print $1'}` != `md5sum "$fBouquet".tmp| awk {'print $1'}` ]; then
				mv "$fBouquet".tmp "$fBouquet"
			else
				rm -f "$fBouquet".tmp
			fi
		done
	fi
}

SleepAndReboot () {
  while true
  do
	sleep 5; reboot; sleep 9; killall -9 enigma2
  done
}

wget -q "$URL$FILENAME"_md5.txt -P /tmp
if [ "$?" = "0" ]; then
  if [ -s /tmp/"$FILENAME"_md5.txt ]; then
	CrntMD5=`cat -u /tmp/"$FILENAME"_md5.txt| head -n1`
	[ -e "$shTXT" ] && PrevMD5=`cat -u "$shTXT"| head -n1` || PrevMD5="00"
	if [ "$PrevMD5" = "$CrntMD5" ]; then
		echo "Datei auf dem Server ist aktuell"
	else
	  wget $URL$FILENAME -P /tmp
	  if [ "$?" = "0" ]; then
	    if [ -s /tmp/$FILENAME ]; then
		echo extract files
		echo "$CrntMD5">"$shTXT"
		#rm -f "$DirEnigma"userbouquet.*
		#init 4; sleep 4; killall -9 enigma2; sleep 2
		tar -zxf /tmp/$FILENAME -C /
		if [ `grep -ics "DVB-T" /proc/bus/nim_sockets` -eq 0 ]; then
			RemoveTerrestialBouquets
		elif [ `grep -ics "TrialTuner" /proc/bus/nim_sockets` -gt 0 ] || [ -e /lib/modules/*/extra/trialtunerdriver.ko ]; then
			sed -e '/^[[:space:]]s\ .*:.*:.*:.*:.*:.*:.*:.*:/,/\// s/:[01]$/:2/' "$fLAMEDB">"$fTMP"
			[ -s "$fTMP" ] && mv "$fTMP" "$fLAMEDB"
			sed -r '/^[[:space:]]s\ .*:.*/,/\// s|(s ([^:]+:){5})([^:]+:){1}(.*)|\12:\4|' "$fLAMEDB">"$fTMP"
			[ -s "$fTMP" ] && mv "$fTMP" "$fLAMEDB"
			#RebootBox=1
		fi
		[ -e "$fLAMEDB"_patch_dvbt ] && PatchTerrestialRegionalTransponders
		if grep -qs ".sat.3590." "$E2conf"|| grep -qs ".diseqc[A-D]=3601" "$E2conf"|| grep -qs ".sat.49." "$E2conf"|| grep -qs ".diseqc[A-D]=49" "$E2conf"|| grep -qs ".sat.50." "$E2conf"|| grep -qs ".diseqc[A-D]=50" "$E2conf"|| grep -qs ".sat.158." "$E2conf"|| grep -qs ".diseqc[A-D]=158" "$E2conf"; then
			echo change Sat positions in Enigma2 config
			echo restart GUI && sleep 2
			sed -e 's/\.sat\.3590\./\.sat\.3592\./' -e '/^config.Nims.[0-9].diseqc[A-D]=/{s/=3601/=3602/}' -e 's/\.sat\.49\./\.sat\.48\./' -e '/^config.Nims.[0-9].diseqc[A-D]=/{s/=49/=48/}' -e 's/\.sat\.50\./\.sat\.48\./' -e '/^config.Nims.[0-9].diseqc[A-D]=/{s/=50/=48/}' -e 's/\.sat\.158\./\.sat\.160\./' -e '/^config.Nims.[0-9].diseqc[A-D]=/{s/=158/=160/}' "$E2conf">"$E2conf".tmp
			[ -s "$E2conf".tmp ] && mv "$E2conf".tmp "$E2conf"
			#[ "$RebootBox" = "1" ] && reboot || init 3
		#else
			#echo reaload services and bouquets
			#wget -O /dev/null -q http://127.0.0.1/web/servicelistreload?mode=0
			#[ "$RebootBox" = "1" -o `grep -ics "DVB" /proc/bus/usb/devices` -gt 0 ] && reboot || init 3
		fi
		CleanBouquetsFromNotInstalledSattelites
		if [ `ps ax| grep -v grep| grep -c enigma2` -gt 0 ]; then
			echo restart box
			SleepAndReboot &
			killall -9 enigma2
		fi
	    else
		echo Zero len /tmp/$FILENAME
	    fi
	  else
		echo !!! Download $URL$FILENAME failed !!!
	  fi
	fi
  else
		echo Zero len /tmp/"$FILENAME"_md5.txt
  fi
else
  echo !!! Download "$URL$FILENAME"_md5.txt failed !!!
fi

exit 0

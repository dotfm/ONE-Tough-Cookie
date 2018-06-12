###
##		MacOS Darwin Kernel Hardend   
###				TOUGH COOKIE EDITION
##		author'd by dothop'dotaxis.
###
##
#	I. PowerLog Settings
##
sudo psmet -a hibernatemode 25 &&\
sudo pmset -a destroyfvkeyonstandby 1 

sudo pmset -a womp 0 &&\
sudo pmset -a powernap 0 &&\ 
sudo pmset -a standby 1 &&\
sudo pmset -a standbydelay 180 &&\
sudo pmset -a tcpkeepalive 0 &&\
sudo pmset -a ttyskeepawake 0 &&\
sudo pmset -a autopoweroff 1 &&\
sudo pmset -a autopoweroffdelay 210

defaults write com.apple.Terminal SecureKeyboardEntry -int 1 &&\
defaults write com.apple.screensaver askForPassword -int 1 && \
defaults write com.apple.screensaver askForPasswordDelay -int 0

##
#	II.AppFW Socketfilterfw 
##

sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on &&\
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on &&\
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on &&\
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off &&\
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
sudo pkill -HUP socketfilterfw

##
#	III. Harden sysctl.conf ipv6 Specific
##

cat << EOF > /etc/sysctl.conf
sysctl net.inet6.ip6.use_tempaddr=0
sysctl net.inet.inet6.use_tempaddr=0
sysctl net.inet6.ip6.forwarding=0 # not a router
sysctl net.inet6.ip6.accept_rtadv=0 # disable RA
sysctl net.inet6.ip6.maxifprefixes=1 # def 16 prefix
sysctl net.inet6.ip6.maxifdefrouters=1 # maximum acceptable default routers via RA
sysctl sysctl net.inet6.ip6.use_deprecated=0 # disable ipv6 deprecated addr
sysctl net.inet6.ip6.hdrnestlimit=0 # limit header options 0
sysctl net.inet6.ip6.dad_count=0 # disable duplicate addr detection
sysctl net.inet6.icmp6.nodeinfo=0 # disable icmpv6 redirects not a router
sysctl net.inet6.ip6.maxfrags=0 # no fragmented packets default 2048
sysctl net.inet6.ip6.maxfragpackets=0 # default value 1024


#sysctl net.inet6.ip6.neighborgcthresh: 1024 # default parameter is 1024 ##however neighbor cache exhaustation attacks arent uncommon, thus this ##paramater #must be based upon a certain environment equilibrium factor between ##system #memory and hosts present in local link env.

##
#	IV.Further sysctl 
##

##
##	V.Homebrew and Standard Security Pkgs
# Install Homebrew Package Manger
#/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
##
## open up a new terminal window
brew update && brew update && brew upgrade && brew doctor 

##
#	a. 		networking,stubby,dnsutils,packet forwarding
brew install openssl 
brew install curl --with-openssl
brew install wget

brew install stubby
sudo brew services start stubby

networksetup -listallnetworkservices 2>/dev/null | grep -v '*' | while read x ; do 
	networksetup -setdnsservers "$x" 127.0.0.1 ::1
done

##
#	b. 		Edit pf.conf
nano /etc/pf.conf
set default block policy drop 
set ruleset optimization basic
block drop quick on !lo0 proto udp from any to any port = 53

## reload packetfiltering with sudo pfctl -ef /etc/pf.conf

# Test Stubby
dig @127.0.0.1 www.example.com
# output should register NOERROR followed query flags
## check that base validation against publicdns resolvers is blocked
dig @8.8.8.8 www.example.com
# connection output should register default timeout and unanswered query
##

##
#		VII. GPG 
##
brew instal gnupg2 pinentry-mac coreutils #haveged(entropy)
#	ykpam and yubico dyld
#brew install yubico-pam ykpers (yubico-pam's default software license had been #expired since September 2017 >> please check the validity before proceeding.  

##
#		/etc/hosts 
##
## 	Curl steven black's raw hosts file and append it to /etc/hosts OR
#	host "Pi-Hole" dns blackhole somewhere on ur 
#
# macOS's Fortress ProxyList.pac autoconfig hosted on github 
# https://raw.githubusercontent.com/essandess/easylist-pac-privoxy/master/proxy.pac 

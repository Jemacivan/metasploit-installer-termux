ruby2_install(){
	pkg install wget -y
	wget -O ruby2_2.7.2-3.deb https://github.com/Hax4us/TermuxBlack/raw/master/dists/termuxblack/main/binary-aarch64/ruby2_2.7.2-3_aarch64.deb
	apt -y install ./ruby2_2.7.2-3.deb
}


pkg update
ruby2_install
pkg upgrade -y -o Dpkg::Options::="--force-confnew"
pkg install -y autoconf bison clang coreutils curl findutils apr apr-util postgresql openssl readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils ncurses git wget unzip zip tar termux-tools termux-elf-cleaner pkg-config git -o Dpkg::Options::="--force-confnew"

source <(curl -sL https://github.com/termux/termux-packages/files/2912002/fix-ruby-bigdecimal.sh.txt)
rm -rf $HOME/metasploit-framework
echo
cd $HOME
git clone --depth 1 https://github.com/rapid7/metasploit-framework.git

cd $HOME/metasploit-framework
sed '/rbnacl/d' -i Gemfile.lock
sed '/rbnacl/d' -i metasploit-framework.gemspec
gem install bundler
sed 's|nokogiri (1.*)|nokogiri (1.8.0)|g' -i Gemfile.lock

gem install nokogiri -v 1.8.0 -- --use-system-libraries

gem install actionpack
bundle update activesupport
bundle update --bundler
bundle install -j5
$PREFIX/bin/find -type f -executable -exec termux-fix-shebang \{\} \;
rm ./modules/auxiliary/gather/http_pdf_authors.rb
if [ -e $PREFIX/bin/msfconsole ];then
	rm $PREFIX/bin/msfconsole
fi
if [ -e $PREFIX/bin/msfvenom ];then
	rm $PREFIX/bin/msfvenom
fi
ln -s $HOME/metasploit-framework/msfconsole /data/data/com.termux/files/usr/bin/
ln -s $HOME/metasploit-framework/msfvenom /data/data/com.termux/files/usr/bin/
termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/2.4.0/gems/pg-0.20.0/lib/pg_ext.so

cd $HOME/metasploit-framework/config
curl -sLO https://raw.githubusercontent.com/limitedeternity/metasploit_in_termux/master/database.yml

mkdir -p $PREFIX/var/lib/postgresql
initdb $PREFIX/var/lib/postgresql

pg_ctl -D $PREFIX/var/lib/postgresql start
createuser msf
createdb msf_database
pg_ctl -D $PREFIX/var/lib/postgresql stop

cd $HOME
curl -sLO https://raw.githubusercontent.com/limitedeternity/metasploit_in_termux/master/postgresql_ctl.sh
chmod +x postgresql_ctl.sh
./postgresql_ctl.sh start

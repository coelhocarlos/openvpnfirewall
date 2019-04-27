BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BOLD=`tput bold`
RESET=`tput sgr0`

#echo -e "hello ${RED}some red text${RESET} world"
# Abre para uma faixa de endereços da rede local
# iptables -A INPUT -p tcp --syn -s 192.168.0.0/255.255.255.0 -j ACCEPT
#limpando Regras
echo -e "${MAGENTA} Limpando as Chains";
# Limpando as Chains
 iptables -F INPUT
 iptables -F OUTPUT
 iptables -F FORWARD
 iptables -F -t filter
 iptables -F POSTROUTING -t nat
 iptables -F PREROUTING -t nat
 iptables -F OUTPUT -t nat
 iptables -F -t nat
 iptables -t nat -F
 iptables -t mangle -F
 iptables -X
echo -e "${GREEN}Chains limpos e OK";
echo -e "${MAGENTA}Zerando contadores";
 # Zerando contadores
 iptables -Z
 iptables -t nat -Z
 iptables -t mangle -Z
echo -e "${GREEN}Contadores Zerados";
echo -e "${MAGENTA}Definindo Polticas Padrões";
 # Define politicas padrao ACCEPT
 iptables -P INPUT ACCEPT
 iptables -P OUTPUT ACCEPT
 iptables -P FORWARD ACCEPT
echo -e "${GREEN}Polticas Padrões definidas";
echo -e "${MAGENTA}Liberando trafico em loopback";
# Allow traffic on loopback
 iptables -A INPUT -i lo -j ACCEPT
 iptables -A OUTPUT -o lo -j ACCEPT
echo -e "${GREEN} trafico em loopback liberado";
echo -e "${MAGENTA}Liberando conecções estabelicidas";
 # Allow all inbound established connections
 iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
echo -e "${GREEN} conecções estabelicidas liberadas";
 # Allow all outbound established connections
echo -e "${MAGENTA}Allow all outbound established connections";
 iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
echo -e "${GREEN}established connections outbond";
echo -e "${MAGENTA}Abrindo Portas para a internet";
 # Abre uma porta (inclusive para a Internet)
 iptables -A INPUT -p tcp --destination-port 21 -j ACCEPT
echo -e "${GREEN} 21 OK FTP";
 iptables -A INPUT -p tcp --destination-port 22 -j ACCEPT
echo -e "${GREEN} 22 OK SSH";
 iptables -A INPUT -p tcp --destination-port 2121 -j ACCEPT
echo -e "${GREEN} Porta alternativa para FTP 2121 OK";
 iptables -A INPUT -p tcp --destination-port 53 -j ACCEPT
echo -e "${GREEN} 53 Porta de TFTP OK";
 iptables -A INPUT -p tcp --destination-port 80 -j ACCEPT
echo -e "${GREEN} Porta web 80 OK";
 iptables -A INPUT -p tcp --destination-port 443 -j ACCEPT
echo -e "${GREEN} Porta web segura 443 OK";
 iptables -A INPUT -p tcp --destination-port 8080 -j ACCEPT
echo -e "${GREEN} Porta web 8080 OK";
 iptables -A INPUT -p tcp --destination-port 8081 -j ACCEPT
echo -e "${GREEN} Porta web 8081 OK";
 iptables -A INPUT -p tcp --destination-port 8082 -j ACCEPT
echo -e "${GREEN} Porta web 8082 OK";
 iptables -A INPUT -p tcp --destination-port 8083 -j ACCEPT
echo -e "${GREEN} Porta web 8083 OK";
 iptables -A INPUT -p tcp --destination-port 8084 -j ACCEPT
echo -e "${GREEN} Porta web 8084 OK";
 iptables -A INPUT -p tcp --destination-port 10000 -j ACCEPT
echo -e "${GREEN} Porta Webmin 10000 padrão OK";
 iptables -A INPUT -p tcp --destination-port 11000 -j ACCEPT
echo -e "${GREEN} Porta Webmin 11000 Alternativa OK";
 iptables -A INPUT -p tcp -m tcp --destination-port 25565 -j ACCEPT


# Allow incoming SSH
echo -e "${MAGENTA=}Abrindo Incomming para SSH";
 iptables -A INPUT -i enp2s0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
 iptables -A OUTPUT -o enp2s0  -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
echo -e "${GREEN} Porta Aberta para SSH OK";
echo -e "${MAGENTA}Rediecionamento de Portas 80 para 8080";
# Redirect 8080 to 80
 iptables -A INPUT -i enp2s0 -p tcp --dport 80 -j ACCEPT
 iptables -A INPUT -i enp2s0 -p tcp --dport 8585 -j ACCEPT
 iptables -A PREROUTING -t nat -i enp2s0 -p tcp --dport 8585 -j REDIRECT --to-port 80
echo -e "${GREEN} Adcionado Portas 80 para 8080 e OK";
echo -e "${MAGENTA}Liberando Samba portas padores Rede ";
# Allow incoming Samba
sudo iptables -A INPUT -p udp -m udp --dport 137 -j ACCEPT
sudo iptables -A INPUT -p udp -m udp --dport 138 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 139 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 445 -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/24 -p udp -m udp --dport 137 -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/24 -p udp -m udp --dport 138 -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/24 -p tcp -m tcp --dport 139 -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/24 -p tcp -m tcp --dport 445 -j ACCEPT
echo -e "${GREEN} Portas Liberadas SAMBA 137 138 139 e 445 ";
echo -e "${MAGENTA}Liberando OPENVPN";
#VPN
 iptables -A INPUT -i enp2s0 -m state --state NEW -p udp --dport 1194 -j ACCEPT
 iptables -A INPUT -i tun+ -j ACCEPT
 iptables -A FORWARD -i tun+ -j ACCEPT
 iptables -A FORWARD -i tun+ -o enp2s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
 iptables -A FORWARD -i enp2s0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
 iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o enp2s0 -j MASQUERADE
 iptables -A OUTPUT -o tun+ -j ACCEPT
echo -e "${GREEN} OPENVPN Liberado e OK";
echo -e "${MAGENTA} Liberando Portas Alternativas para FTP usando 2121";
#FTP
 modprobe ip_conntrack_ftp
 modprobe ip_nat_ftp
 iptables -A PREROUTING -t raw -p tcp --dport 2121 -d 192.168.0.50 -j CT --helper ftp
 iptables -t nat -A PREROUTING -p tcp --destination-port 20:2121 -i enp2s0 -j DNAT --to-destination 192.168.0.50
echo -e "${GREEN} Porta alternativa liberada FTP 21 para redirecionada 2121";
echo -e "${MAGENTA} Ignorando pings ICMP";
# Ignora pings
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all
echo -e "${MAGENTA} Proteções diversas contra portscanners, ping of death, ataques DoS, etc.";
# Proteções diversas contra portscanners, ping of death, ataques DoS, etc.
 iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
 iptables -A FORWARD -p tcp -m limit --limit 1/s -j ACCEPT
 iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
 iptables -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
 iptables -A FORWARD --protocol tcp --tcp-flags ALL SYN,ACK -j DROP
#iptables -A FORWARD -m unclean -j DROP
echo -e "${MAGENTA}Permitindo o estabelecimento de novas conexões iniciadas por você coração do firewall";
# Permite o estabelecimento de novas conexões iniciadas por você // coração do firewall //
 iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
 iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED,NEW -j ACCEPT

echo -e "${MAGENTA}Abre para a interface de loopback.";
echo -e "${MAGENTA}Esta regra é essencial para o KDE e outros programas gráficos";
echo -e "${MAGENTA}funcionarem adequadamente.";
# Abre para a interface de loopback.
# Esta regra é essencial para o KDE e outros programas gráficos
# funcionarem adequadamente.
 iptables -A INPUT -p tcp --syn -s 127.0.0.1/255.0.0.0 -j ACCEPT
 iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

echo -e "${MAGENTA}Ignorando qualquer pacote de entrada, vindo de qualquer endereço, a menos que especificado o contrário acima. Bloqueia tudo.";
# Ignora qualquer pacote de entrada, vindo de qualquer endereço, a menos que especificado o contrário acima. Bloqueia tudo.
 iptables -A INPUT -p tcp --syn -j DROP
 iptables -P INPUT DROP
 iptables -P FORWARD DROP
 iptables -P OUTPUT  DROP
echo -e "${YELLOW} FIREWALL ADICIONADO GOOD LUCK !!!!";
echo -e "${RESET}"
 sudo iptables-save > /etc/webmin/firewall/iptables.save
 sudo iptables-restore < /etc/webmin/firewall/iptables.save

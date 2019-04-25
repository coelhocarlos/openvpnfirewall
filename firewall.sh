
# Abre para uma faixa de endereços da rede local
# iptables -A INPUT -p tcp --syn -s 192.168.0.0/255.255.255.0 -j ACCEPT
#limpando Regras
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
 # Zerando contadores
 iptables -Z
 iptables -t nat -Z
 iptables -t mangle -Z
 # Define politicas padrao ACCEPT
 iptables -P INPUT ACCEPT
 iptables -P OUTPUT ACCEPT
 iptables -P FORWARD ACCEPT
# Allow traffic on loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# Allow all inbound established connections
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow all outbound established connections
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
 
# Abre uma porta (inclusive para a Internet)
iptables -A INPUT -p tcp --destination-port 21 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 22 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 2121 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 53 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 80 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 443-j ACCEPT
iptables -A INPUT -p tcp --destination-port 8080 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 8081 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 8082 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 8083 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 8084 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 10000 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 11000 -j ACCEPT
iptables -A INPUT -p tcp -m tcp ---destination-port 25565 -j ACCEPT


# Allow incoming SSH

iptables -A INPUT -i enp2s0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o enp2s0  -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT


# Allow incoming Samba
sudo iptables -A INPUT -p udp -m udp --dport 137 -j ACCEPT
sudo iptables -A INPUT -p udp -m udp --dport 138 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 139 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 445 -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/24 -p udp -m udp --dport 137 -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/24 -p udp -m udp --dport 138 -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/24 -p tcp -m tcp --dport 139 -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/24 -p tcp -m tcp --dport 445 -j ACCEPT


#VPN
iptables -A INPUT -i enp2s0 -m state --state NEW -p udp --dport 1194 -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o enp2s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp2s0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o enp2s0 -j MASQUERADE
iptables -A OUTPUT -o tun+ -j ACCEPT

# Ignora pings
echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all

# Proteções diversas contra portscanners, ping of death, ataques DoS, etc.
iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
iptables -A FORWARD -p tcp -m limit --limit 1/s -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
iptables -A FORWARD --protocol tcp --tcp-flags ALL SYN,ACK -j DROP
iptables -A FORWARD -m unclean -j DROP

# Permite o estabelecimento de novas conexões iniciadas por você // coração do firewall //
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED,NEW -j ACCEPT

# Abre para a interface de loopback.
# Esta regra é essencial para o KDE e outros programas gráficos
# funcionarem adequadamente.
iptables -A INPUT -p tcp --syn -s 127.0.0.1/255.0.0.0 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Ignora qualquer pacote de entrada, vindo de qualquer endereço, a menos que especificado o contrário acima. Bloqueia tudo.
iptables -A INPUT -p tcp --syn -j DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

sudo iptables-save > /etc/webmin/firewall/iptables.save
sudo iptables-restore < /etc/webmin/firewall/iptables.save

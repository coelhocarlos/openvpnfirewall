

Montaremos uma VPN com o seguinte cenário:

openvpn
Porém, é possível futuramente conectar outras filiais a essa mesma VPN.

O primeiro passo que veremos será do lado do servidor da matriz. Neste nosso tutorial usaremos como base um Debian.

Vamos lá!

Instalando o OpenVPN no Servidor da Matriz

A instalação é bem simples, padrão Linux, utilizando o apt.

apt-get install openvpn
Será instalado openvpn e será criado o diretório /etc/openvpn. Antes mesmo de começar a fazer a configuração do servidor da matriz, vamos criar alguns sub-diretórios para melhor organizarmos nossas configurações. Após isso, criaremos nossos certificados.

mkdir /etc/openvpn/certificados /etc/openvpn/config_clientes /etc/openvpn/rotas
Criando as chaves e certificados

Os certificados serão usados tanto pelo servidor da matriz como pelo servidor da filial, de forma que após a verificação destes certificados e que a conexão será estabelecida.

Há um tempo atrás era necessário fazer tudo manualmente através do pacote openssl. Atualmente o OpenVPN criou alguns scripts que facilitam nossa vida.

Esses script ficam em /usr/share/doc/openvpn/examples/easy-rsa/2.0/. Através destes scripts geraremos uma chave certificadora, assinaremos certificados, certificados do servidor o do cliente serão feitos facilmente.

O primeiro passo é acessar o diretório acima:

cd /usr/share/doc/openvpn/examples/easy-rsa/2.0/
Agora vamos editar as variáveis dentro do arquivo vars. As variáveis abaixo deverão ser alteradas para corresponderem com a realidade da sua empresa.

vim vars
Informe os dados correspondentes a localização do servidor da matriz da empresa:

export KEY_COUNTRY=”BR”
export KEY_PROVINCE=”RJ”
export KEY_CITY=”RioDeJaneiro”
export KEY_ORG=”PortalAprendendoLinux”
export KEY_EMAIL=henrique@aprendendolinux.com
Com as variáveis alteradas devemos então executar o script, para que essas variáveis sejam criadas:

./clean-all
source ./vars
O comando clean-all, apagará qualquer variável existente, caso você queira começar todo o processo novamente. Mas tome cuidado pois ele não apaga o diretório keys, que será o local de armazenamento das chaves.

Tenha certeza que as variáveis foram criadas realmente. Um simples echo $KEY_EMAIL, deverá exibir o valor colocado manualmente dentro do arquivo vars. Caso não exista, ou seja, as variáveis não foram criadas, deverá executar o procedimento novamente.

O próximo passo é gerar o Certificado de Autoridade, nossa CA. Ao final deste comando será gerado a nossa CA e as chaves que serão usadas pelo openssl para gerar chaves clients e servers.

./build-ca
A saída do comando exibirá várias informações, obtidas através das variáveis criadas anteriormente.

O próximo passo será gerar o certificado e a chave do servidor da matriz. Existe também um comando bem simples para criar tal chave.

./build-key-server servidor
O comando acima gerará tanto o certificado com extensão crt, como a chave com extensão key, ambos com o nome servidor na pasta keys.

O próximo passo é gerar certificado e chaves para o servidor da filial. Também muito simples.

./build-key filial_01
Este comando deverá ser executado para cada servidor de filial, veja acima que foi executado uma vez, ou seja, foi gerado chaves e certificados para um cliente.

Cuidado para não colocar senha quando solicitado, no servidor da matriz e no servidor da filial, pois caso venha a colocar, essa senha será solicitado quando o serviço openvpn for iniciado. E obviamente, as vezes não é possível estar no local dos servidores, para poder digitar a senha.

No fim de cada processo para gerar as chaves, o script irá perguntar se é você deseja assinar as chaves, e com certeza, deve-se digitar “y” para que o processo termine.

O ultimo ítem a ser feito é gerar os parâmetros do Diffie Hellman . O comando abaixo gerará um arquivo dh(valor).pem. Onde valor, será o valor colocado na variável KEY_SIZE, do arquivo vars. Por padrão 1024. O Diffie Hellman permite que o servidor da filial e o servidor da matriz troquem chaves sobre um meio inseguro sem comprometer a segurança.

./build-dh
Esse é todo o processo para criar as chaves e certificados que serão utilizados pelo servidor da matriz e pelo servidor da filial.

Agora vamos verificar quais ficarão no servidor da matriz e quais ficarão no servidor da filial. Todos os arquivos serão salvas dentro da pasta keys no caminho “/usr/share/doc/openvpn/examples/easy-rsa/2.0/”. Comecemos com o servidor da matriz.

Servidor da Matriz:

ca.crt
dh1024.pem
servidor.crt
servidor.key
Vamos copiar:

cp keys/ca.crt keys/dh1024.pem keys/servidor.crt keys/servidor.key /etc/openvpn/certificados/
Servidor da Filial_01:

ca.crt
filial_01.crt
filial_01.key
Atenção! DEPOIS que você instalar o OpenVPN no servidor da filial e criar o diretório /etc/openvpn/certificados deve-se copiar as chaves:

scp keys/ca.crt keys/filial_01.crt keys/filial_01.key root@ip-da-filial:/etc/openvpn/certificados/
Depois de entregue as chaves do servidor da filial e as chaves do servidor da matriz serem copiadas para dentro de /etc/openvpn/certificados, devemos então criar o arquivo de configuração do servidor da matriz.

Configuração do Servidor da Matriz

No servidor da matriz teremos que criar um arquivo chamado tuno.conf.

vim /etc/openvpn/tuno.conf
Vejamos as configurações dentro do arquivo:

# Dispositivo, podendo ser tap ou tun. O tap permite propagacao de broadcast netbios,
# o que e muito util para redes microsoft. O tun nao permite, de forma que seria necessario
# executar um servidor Wins para localizacao de maquinas windows pelo nome.
dev tap
# Permite o uso de conexoes SSL/TLS e assume ser o Servidor
tls-server
# Anteriormente teriamos apenas o modo p2p ( point-to-point),
# mas nesse contexto, ele e utilizado para tornar o nosso servidor um servidor
# multi-client, e necessario tambem quando fazemos o uso de valores como
# ifconfig-pool, que sera visto adiante.
mode server
# Chaves que foram criadas anteriormente.
ca /etc/openvpn/certificados/ca.crt
cert /etc/openvpn/certificados/servidor.crt
key /etc/openvpn/certificados/servidor.key
dh /etc/openvpn/certificados/dh1024.pem
# Este item permite o compartilhamento de um mesmo certificado
# para duas conexoes. Caso não necessite, remova esta entrada.
#duplicate-cn
# Informar qual IP para conexao tap, ou seja, o endereco IP para a VPN.
ifconfig 20.20.0.1 255.255.255.0
# Informa qual range de endereços IP serao dinamicamente alocados pelas
# conexoes dos clientes.
ifconfig-pool 20.20.0.2 10.0.0.100 255.255.255.0
# Configuração das rotas
script-security 3 system
up /etc/openvpn/rotas/up.sh
down /etc/openvpn/rotas/down.sh
# O comando abaixo permite que os clientes se enxerguem
client-to-client
# Compressao de dados
comp-lzo
# Mantem a interface tun carregada quando a vpn e reiniciada
persist-tun
# Mantem a chave carregada quando a vpn e reiniciada
persist-key
# Caso o IP mude, o tunel continua estabelecido
float
# Executa um ping sobre uma conexao TCP/UDP a cada 10 segundos se nenhum
# pacote tiver sido enviado. Devera ser especificado em ambos os lados,
# e quando usado com tls, o ping e criptografado.
ping 10
# Envia um sinal SIGUSR1 restart apos n segundos. No lado do servidor
# esse sinal e aplicado somente ao objeto do cliente conectado. Pode ser
# usado por exemplo no caso de ddns, quando o endereço de ip e alterado
# no servidor, mas e usado nos clientes como servidor DNS. No modo cliente
# fara com que o cliente push as novas configuraçoes apos n segundos.
ping-restart 120
# O cliente ira usar o ping 10, ping-restart 120 e tera uma rota para rede
# informada no arquivo de configuracao de rotas.
push "ping 10"
push "ping-restart 120"
# Dentro do diretorio setado nesta opcao fica os arquivos de configuracao dos
# clientes da VPN. Neste caso vamos usa-lo para fixar os IPS.
client-config-dir config_clientes
# Verbose mode. Quanto informacao sera enviado ao log. Pode ser configurada de 0 ate 11,
# onde quanto mais alto o valor, mais informacoes sao trazidas. E recomendado o valor 3,
# que e o uso normal. O valor 5 traz caracteres W e R para cada pacotes lido e escrito.
verb 5
# Local para onde o verb ira envia a saida.
log /var/log/openvpn.log
Agora salve e feche o arquivo.

Agora vamos criar a rota da rede do servidor da matriz para a rede do servidor da filial criando e editando o arquivo:

touch /etc/openvpn/rotas/up.sh
vim /etc/openvpn/rotas/up.sh
O conteúdo desse arquivo deverá ser somente isso:

#!/bin/sh
ip route add 172.4.96.0/255.255.255.0 via 10.0.0.2
Precisamos dar permissão de execução no script:

chmod +x /etc/openvpn/rotas/up.sh
Criando o arquivo que remove as rotas:

touch /etc/openvpn/rotas/down.sh
vim /etc/openvpn/rotas/down.sh
O conteúdo desse arquivo deverá ser somente isso:

#!/bin/sh
ip route del 172.4.96.0/255.255.255.0 via 20.20.0.2
Precisamos dar permissão de execução no script:

chmod +x /etc/openvpn/rotas/down.sh
Precisamos também criar e configurar o arquivo no qual iremos definir qual IP o servidor da filial irá assumir:

touch /etc/openvpn/config_clientes/filial_01
vim /etc/openvpn/config_clientes/filial_01
O conteúdo desse arquivo deverá ser somente isso:

ifconfig-push 7.0.0.2 255.255.255.0
Com isso já temos toda configuração do servidor da matriz pronta.

Agora devemos reiniciar o serviço:

/etc/init.d/openvpn restart
Vamos conferir se o serviço subiu:

ifconfig
A saída deve ser assim:


Agora devemos configurar o Servidor da Filial:

Instale o serviço:

apt-get install openvpn
Depois de instalado, vamos criar o arquivo /etc/openvpn/tuno.conf

vim /etc/openvpn/tuno.conf
Ficará assim:

# Dispositivo
dev tap
# Permite o uso de conexoes SSL/TL
tls-client
# Atencao para essa parte, pois aqui devemos apontar
# o ip (ou host) publico do servidor.
remote servidor.matriz.com.br
# Chaves para conexao com o servidor.
ca /etc/openvpn/certificados/ca.crt
key /etc/openvpn/certificados/filial_01.key
cert /etc/openvpn/certificados/filial_01.crt
# Configuração das rotas
script-security 3 system
up /etc/openvpn/rotas.up
down /etc/openvpn/rotas.down
# Mantem a chave carregada quando a vpn e reiniciada.
persist-key
# Pull mode.
pull
# Compressao de dados.
comp-lzo
# Mantem a interface tun carregada quando a vpn e reiniciada.
persist-tun
# Caso o IP mude, o tunel continua estabelecido.
float
# Usuario e grupo utilizados pelo OpenVPN.
user nobody
group nogroup
# Configuracoes de Ping.
ping 10
ping-restart 120
push "ping 10"
push "ping-restart 120"
# Verbose mode.
verb 5
# Local para onde o verb ira envia a saida.
log /var/log/openvpn.log
Agora salve e saia do editor.

Agora vamos criar a rota da rede do servidor da filial para a rede do servidor da matriz criando e editando o arquivo:

touch /etc/openvpn/rotas.up
vim /etc/openvpn/rotas.up
O conteúdo desse arquivo deverá ser somente isso:

#!/bin/sh
ip route add 192.168.0.0/255.255.255.0 via 20.20.0.1
Precisamos dar permissão de execução no script:

chmod +x /etc/openvpn/rotas.up
Criando o arquivo que remove as rotas:

touch /etc/openvpn/rotas.down
vim /etc/openvpn/rotas.down
O conteúdo desse arquivo deverá ser somente isso:

#!/bin/sh
ip route del 192.168.0.0/255.255.255.0 via 20.20.0.1
Precisamos dar permissão de execução no script:

chmod +x /etc/openvpn/rotas.down
Conforme já foi dito lá no início, você deve agora copiar as chaves do servidor da matriz para dentro do servidor da filial:

cd /usr/share/doc/openvpn/examples/easy-rsa/2.0/keys/
scp ca.crt cliente1.crt cliente1.key root@IP_DA_FILIAL:/etc/openvpn/certificados/
Logue no servidor da filial e reinicie o serviço:

/etc/init.d/openvpn restart
Agora vamos verificar se o serviço subiu no servidor da filial:

ifconfig
A saída deve ser igual a do ifconfig mostrado no servidor da matriz, só que com o IP diferente.

Pronto! Sua VPN já está rodando e funcional!

OpenVPN Client no Windows 2000/2003/XP/7/8

Depois disso tudo, seu chefe provavelmente ficou satisfeito com o conceito de VPN, certo? Só que ele te informou que vai viajar, levar seu notebook com Windows e que deseja poder trabalhar utilizando a rede da matriz, mesmo estando longe. E aí? O que você faz?

Se você deseja baixar um vídeo que não está disponível em sua região, instale o Freemake Video Downloader em seu computador com Windows (descubra mais aqui). O programa permite salve vídeos e filmes de uma variedade de sites com configurações do servidor proxy e VPN. Esta excelente ferramenta é muito fácil de usar, além disso, é grátis.

Calma. Relaxa. O procedimento é tão simples quando a implementação do servidor da filial.
Primeiro gere as chaves e certificados normalmente, igualzinho você fez para o servidor da filial.

Depois, no notebook do seu chefe, baixe e instale a última versão do OpenVPN para Windows. Use o link abaixo:

https://openvpn.net/index.php/open-source/downloads.html

Depois de instalado, coloque as chaves (ca.crt, chefe.crt, chefe.key) dentro do seguinte diretório:

C:\Arquivos de Programas\OpenVPN\config\

Feito isso, você deve criar o arquivo “tuno.ovpn” dentro desse mesmo diretório com o seguinte conteúdo:

# Dispositivo
dev tap
# Permite o uso de conexoes SSL/TL
tls-client
# Atencao para essa parte, pois aqui devemos apontar
# o ip (ou host) publico do servidor. No meu caso ficou
# assim
remote servidor.matriz.com.br
# Essas chaves deverao ser copiadas do servidor para o cliente
ca ca.crt
key chefe.key
cert chefe.crt
# Mantém a chave carregada quando a vpn é reiniciada
persist-key
# Pull mode
pull
# Compressão de dados
comp-lzo
# Mantém a interface tun carregada quando a vpn é reiniciada
persist-tun
# Caso o IP mude, o túnel continua estabelecido
float
user nobody
group nogroup
# Configuracoes de Ping
ping 10
ping-restart 120
push "ping 10"
push "ping-restart 120"
# Verbose mode
verb 3
# Rota
route 192.168.0.0 255.255.255.0 20.20.0.1

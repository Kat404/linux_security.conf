# 👤 Privacidad y Anonimato en Red

Este módulo recopila configuraciones prácticas y scripts para mitigar el rastreo en redes físicas, proteger la resolución de nombres DNS, configurar proxies de anonimato locales y establecer reglas de cortafuegos eficientes mediante un enfoque sencillo.

---

## 🛜 1. MAC Address Spoofing (Aleatorización de MAC)

Cada tarjeta de red posee un identificador físico único de 48 bits conocido como dirección MAC. Cuando te conectas a redes Wi-Fi públicas o corporativas, este identificador permite rastrear de forma persistente tu dispositivo.

### Configuración en NetworkManager

La forma más limpia en distribuciones modernas (como Arch Linux, Debian, Ubuntu) es configurar **NetworkManager** para aleatorizar la MAC automáticamente tanto al escanear redes como al conectarse.

El script [`mac_spoofer.sh`](./mac_spoofer.sh) crea el siguiente archivo de configuración `/etc/NetworkManager/conf.d/30-mac-randomization.conf`:

```ini
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
```

_Esto genera una dirección MAC aleatoria diferente cada vez que te asocias a una red Wi-Fi o conectas un cable Ethernet._

---

## 🔒 2. DNS Seguro (DNS sobre TLS - DoT)

Por defecto, las consultas DNS se envían en texto plano (puerto 53), lo que permite a tu ISP o a un atacante local (MITM) ver y registrar todos los dominios que visitas, e incluso manipular las respuestas (DNS Spoofing).

**DNS over TLS (DoT)** cifra todas las consultas DNS dentro de una sesión TLS segura (puerto 853).

### Configuración nativa con `systemd-resolved`

`systemd-resolved` es la forma más limpia y ligera de implementar DoT en sistemas modernos sin software adicional pesado.

1. Edita el archivo `/etc/systemd/resolved.conf` configurando servidores DNS seguros con soporte DoT y DNSSEC (ej. **Quad9** sin logs y con filtro de malware, o **Mullvad**):

   ```ini
   [Resolve]
   DNS=9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net
   FallbackDNS=45.90.28.0#dns.nextdns.io
   Domains=~.
   DNSOverTLS=yes
   DNSSEC=yes
   ```

   * El parámetro `Domains=~.` indica a `resolved` que envíe todas las consultas DNS al servidor configurado.
   * `DNSSEC=yes` activa la validación criptográfica en el cliente de las firmas DNSSEC para garantizar la integridad y autenticidad de los registros (evitando envenenamiento de caché y falsificaciones). Si el ISP o la red bloquean o alteran estas firmas, la resolución fallará por seguridad. Si prefieres tolerancia a fallos en redes hostiles a DNSSEC a costa de seguridad, usa `allow-downgrade`.

2. Reinicia e inicia el servicio:

   ```bash
   sudo systemctl restart systemd-resolved
   sudo systemctl enable systemd-resolved
   ```

3. Verifica el estado y el cifrado TLS con:

   ```bash
   resolvectl status
   ```

---

## 🧅 3. Enrutamiento Tor (Anonimato en CLI)

Para navegar o realizar consultas de forma totalmente anónima, puedes utilizar la red **Tor** como un proxy local.

### Instalación

- **Arch Linux:** `sudo pacman -S tor torsocks`
- **Debian/Ubuntu:** `sudo apt install tor torsocks`

### Iniciar el servicio local

```bash
sudo systemctl start tor
sudo systemctl enable tor
```

_Tor levantará un proxy SOCKS5 local por defecto en `127.0.0.1:9050`._

### Uso en terminal

Para forzar a cualquier comando de terminal a enrutar su tráfico a través del proxy de Tor de forma transparente, antepón la utilidad `torsocks`:

```bash
# Ejemplo: Verificar tu dirección IP externa
torsocks curl https://check.torproject.org/api/ip
```

---

## 🧱🔥 4. Firewall Simple y Kill-Switch para VPN con UFW

**UFW** (Uncomplicated Firewall) es un frontend amigable para gestionar reglas de cortafuegos en Linux sin la complejidad de escribir reglas directas de iptables o nftables.

### Instalación y Configuración Básica

1. Instalar el paquete:

   ```bash
   # Arch Linux
   sudo pacman -S ufw
   # Debian/Ubuntu
   sudo apt install ufw
   ```

2. Establecer políticas estrictas por defecto (bloquear todo lo entrante, permitir lo saliente):

   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   ```

3. Activar el firewall:

   ```bash
   sudo ufw enable
   sudo systemctl enable ufw
   ```

### 🔒 Implementar un Kill-Switch para VPN

Si utilizas una VPN (como OpenVPN o WireGuard) y esta se desconecta, tu sistema continuará enviando tráfico a través de tu interfaz de red pública de forma predeterminada, exponiendo tu IP real (fuga de tráfico). Un **Kill-Switch** bloquea todo el tráfico saliente si no pasa por el túnel de la VPN.

El script [`ufw_setup.sh`](./ufw_setup.sh) automatiza la configuración de este comportamiento de la siguiente manera:

1. Permite la salida exclusiva de la IP del servidor de tu VPN a través de tu interfaz física.
2. Permite todo el tráfico entrante y saliente a través de la interfaz de la VPN (por ejemplo, `tun0` o `wg0`).
3. Bloquea cualquier otro intento de tráfico saliente a través de tu interfaz de red física normal (como `wlan0` o `eth0`).

🚀 WebCopilot v2.3 - Presentación para Grupos de Ciberseguridad

📋 ¿Qué es WebCopilot?

WebCopilot v2.3 es un framework de reconocimiento web automatizado con IA integrada, diseñado para pentesters, bug bounty hunters y equipos de seguridad ofensiva.

───

🎯 CARACTERÍSTICAS PRINCIPALES

| Feature                  | Descripción                          | Herramientas                       |
| ------------------------ | ------------------------------------ | ---------------------------------- |
| 🔍 Subdomain Enumeration | Descubrimiento masivo de subdominios | Assetfinder, Subfinder, Amass      |
| 🟢 Live Host Detection   | Detección de hosts activos           | httpx                              |
| 🌐 URL Collection        | Recolección extendida de URLs        | Waybackurls, GAU, Katana, GoSpider |
| 🔓 Port Scanning         | Escaneo completo de puertos          | Nmap (-p-)                         |
| ⚠️ Vulnerability Scan    | Detección de vulnerabilidades        | Nuclei, Dalfox (XSS)               |
| 🤖 AI Analysis           | Análisis inteligente con IA local    | Ollama + Llama3.2                  |
| 📬 Telegram Notify       | Notificaciones en tiempo real        | Telegram Bot API                   |

───

💀 FLUJO DE TRABAJO

┌─────────────────────────────────────────────────────────────────┐
│                    WEBCOPILOT PIPELINE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1️⃣ SUBDOMAINS  →  2️⃣ LIVE CHECK  →  3️⃣ URL ENUMERATION      │
│     (assetfinder)      (httpx)          (waybackurls, gau)      │
│     (subfinder)                         (katana, gospider)      │
│     (amass)                                                     │
│                                                                 │
│  4️⃣ PORT SCAN   →  5️⃣ VULN SCAN   →  6️⃣ AI ANALYSIS          │
│     (nmap -p-)        (nuclei)         (ollama/llama3.2)       │
│                       (dalfox)                                  │
│                                                                 │
│  📬 TELEGRAM NOTIFICATIONS (cada fase)                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

───

🛠️ COMANDOS DE USO

Escaneo Básico

./webcopilot.sh -d ejemplo.com

Escaneo Completo con IA

./webcopilot.sh -d ejemplo.com -a -i -p -n

Con Notificaciones Telegram

./webcopilot.sh -d ejemplo.com -n -T TU_TOKEN -C TU_CHAT_ID

Opciones Disponibles

-d  → Target (requerido)
-a  → Full scan (subdomains + vuln)
-o  → Carpeta de output
-t  → Threads (default: 50)
-i  → AI Analysis con Ollama
-p  → Port scan completo (nmap -p-)
-n  → Telegram notifications
-T  → Telegram Bot Token
-C  → Telegram Chat ID

───

📊 OUTPUT GENERADO

webcopilot-20260330-221000-ejemplo.com/
├── subs.txt              # Subdominios encontrados
├── live.txt              # Hosts activos
├── urls.txt              # URLs recolectadas
├── params.txt            # Parámetros para fuzzing
├── ports.txt             # Escaneo de puertos (nmap)
├── open_ports_summary.txt # Puertos abiertos
├── nuclei.txt            # Vulnerabilidades (Nuclei)
└── xss.txt               # XSS findings (Dalfox)

───

🔥 PUNTOS FUERTES

| Ventaja           | Descripción                                               |
| ----------------- | --------------------------------------------------------- |
| 🤖 IA Integrada   | Análisis automático con Ollama (local, sin APIs externas) |
| ⚡ Paralelización  | Multi-threading configurable (default: 50)               |
| 📬 Notificaciones | Telegram en tiempo real por cada fase completada          |
| 🔧 Modular        | Cada función puede activarse/desactivarse                 |
| 📁 Organizado     | Output estructurado por fecha/target                      |
| 🆓 Open Source    | Bash puro, sin dependencias complejas                     |

───

🎯 CASOS DE USO

1. Bug Bounty Hunting

# Reconocimiento rápido antes de testing manual
./webcopilot.sh -d target.com -a -t 100

2. Pentesting Corporativo

# Escaneo completo con notificaciones al equipo
./webcopilot.sh -d cliente.com -a -i -p -n -T TOKEN -C CHAT_ID

3. Auditoría de Superficie de Ataque

# Monitoreo periódico de múltiples dominios
for domain in $(cat domains.txt); do
  ./webcopilot.sh -d $domain -a -o reports/$domain
done

4. CTF / Competencias

# Reconocimiento rápido con IA para sugerencias
./webcopilot.sh -d ctf-target.com -a -i

───

📈 COMPARATIVA CON OTRAS HERRAMIENTAS

| Herramienta | Subdomains | URLs | Ports | Vulns | IA | Notifications |
| ----------- | ---------- | ---- | ----- | ----- | --- | ------------- |
| WebCopilot  | ✅          | ✅    | ✅     | ✅     | ✅  | ✅             |
| Subfinder   | ✅          | ❌    | ❌     | ❌     | ❌  | ❌             |
| Amass       | ✅          | ❌    | ❌     | ❌     | ❌  | ❌             |
| Nuclei      | ❌          | ❌    | ❌     | ✅     | ❌  | ❌             |
| Recon-ng    | ✅          | ✅    | ❌     | ❌     | ❌  | ❌             |
| WebCopilot  | ✅          | ✅    | ✅     | ✅     | ✅  | ✅             |

───

⚠️ CONSIDERACIONES DE SEGURIDAD

✅ Uso Responsable

⚠️ Use with caution. You are responsible for your actions.

📋 Best Practices

• Solo targets autorizados (bug bounty programs, clientes, propios)
• Rate limiting para evitar DoS accidental
• Respetar robots.txt cuando sea aplicable
• Documentar todos los hallazgos
• Reportar responsablemente vulnerabilidades encontradas

───

🔧 REQUISITOS DE INSTALACIÓN

Dependencias Principales

# Go tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/jaeles-project/gospider@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/hahwul/dalfox/v2/cmd/dalfox@latest

# System tools
sudo apt install nmap assetfinder amass

# AI (opcional)
curl https://ollama.ai/install.sh | sh
ollama pull llama3.2

───

📊 ESTADÍSTICAS DE EJEMPLO

═══════════════════════════════════════
[✓] DONE
═══════════════════════════════════════
Output: /home/kali/webcopilot-20260330-221000-target.com
 📋 subs.txt (156)
 🟢 live.txt (43)
 🌐 urls.txt (8542)
 🔧 params.txt (327)
 🔍 ports.txt (nmap full)
 🔓 open_ports_summary.txt (12)
 ⚠️ nuclei.txt (23)
 💉 xss.txt (5)

───

🎓 VALOR PARA EQUIPOS DE SEGURIDAD

| Beneficio           | Impacto                                     |
| ------------------- | ------------------------------------------- |
| ⏱️ Ahorro de Tiempo | 80% menos tiempo en reconnaissance manual   |
| 🎯 Cobertura        | 4-5 herramientas en 1 solo script           |
| 🤖 IA Asistiva      | Sugiere próximos pasos basados en hallazgos |
| 📬 Colaboración     | Todo el equipo recibe notificaciones        |
| 📁 Documentación    | Output estructurado para reportes           |
| 🔁 Reproducible     | Mismo scan = mismos resultados              |

───

🚀 PRÓXIMAS MEJORAS (Roadmap)

• [ ] Integración con Shodan API
• [ ] Soporte para múltiples targets simultáneos
• [ ] Export a PDF/HTML reports
• [ ] Integración con Jira/Trello para tracking
• [ ] Web UI opcional
• [ ] Docker container
• [ ] API REST para integración con otros tools

───

📞 CONTACTO Y CRÉDITOS

Version: 2.3.0
Original Banner: G!2m0
AI Enhanced Edition:
@HackCrack:  @hackingteamprohackers
Update & Mejoras: @h4r5h1t @hackingteamprohackers

⚠️ Uso exclusivo para fines educativos y autorizados.

─── 

🎯 FRASE PARA CERRAR

"El reconnaissance es el 80% del éxito en un pentest. WebCopilot automatiza ese 80% para que te concentres en el 20% que requiere creatividad humana."

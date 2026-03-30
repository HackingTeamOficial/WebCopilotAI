#!/bin/bash
# WebCopilot v2.3 - CON IA INTEGRADA 🤖
# Banner original de G!2m0

VERSION="2.3.0"

NORMAL="\e[0m"			
RED="\033[0;31m" 		
GREEN="\033[0;32m"		   
BOLD="\033[01;01m"    	
YELLOW="\033[1;33m"
LBLUE="\033[1;34m"			
LCYAN="\033[1;36m"
MAGENTA="\033[1;35m"

banner(){
echo -e "${BOLD}${LRED}                     
                                ──────▄▀▄─────▄▀▄
                                ─────▄█░░▀▀▀▀▀░░█▄
                                ─▄▄──█░░░░░░░░░░░█──▄▄
                                █▄▄█─█░░▀░░┬░░▀░░█─█▄▄█
 ██╗░░░░░░░██╗███████╗██████╗░░█████╗░░█████╗░██████╗░██╗██╗░░░░░░█████╗░████████╗
░██║░░██╗░░██║██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║██║░░░░░██╔══██╗╚══██╔══╝
░╚██╗████╗██╔╝█████╗░░██████╦╝██║░░╚═╝██║░░██║██████╔╝██║██║░░░░░██║░░██║░░░██║░░░
░░████╔═████║░██╔══╝░░██╔══██╗██║░░██╗██║░░██║██╔═══╝░██║██║░░░░░██║░░██║░░░██║░░░
░░╚██╔╝░╚██╔╝░███████╗██████╦╝╚█████╔╝╚█████╔╝██║░░░░░██║███████╗╚█████╔╝░░░██║░░░
░░░╚═╝░░░╚═╝░░╚══════╝╚═════╝░░╚════╝░░╚════╝░╚═╝░░░░░╚═╝╚══════╝░╚════╝░░░░╚═╝░░░"
echo -e "${NORMAL}[●] Version: ${VERSION} | @h4r5h1t @hackingteamprohackers=UPDATE a mejoras | G!2m0"
echo -e "${MAGENTA}[🤖] AI Enhanced Edition by @hackingteamprohackers${NORMAL}\n"
echo -e "${YELLOW}[!] Use with caution. You are responsible for your actions.${NORMAL}\n"
}

usage() {
    echo "Usage: webcopilot -d <domain> [-a] [-o folder] [-t threads] [-i] [-p] [-n] [-T token] [-C chatid]"
    echo "  -d domain     Target (required)"
    echo "  -a            Full scan (subdomains + vuln)"
    echo "  -o folder     Output folder"
    echo "  -t threads    Threads (default: 50)"
    echo "  -i            Enable AI Analysis"
    echo "  -p            Enable port scan (all ports)"
    echo "  -n            Enable Telegram notifications"
    echo "  -T token      Telegram Bot Token"
    echo "  -C chatid     Telegram Chat ID"
    exit 0
}

# PATH
export PATH=$PATH:~/go/bin

# ─────────────────────────────────────────
# TELEGRAM NOTIFICATION FUNCTION
# ─────────────────────────────────────────
telegram_notify() {
    local message=$1

    if [ -z "$TELEGRAM_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
        echo -e "${YELLOW}[!] Telegram: TOKEN o CHAT_ID no configurados${NORMAL}"
        return 1
    fi

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d parse_mode="Markdown" \
        -d text="$message" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Notificación Telegram enviada${NORMAL}"
    else
        echo -e "${RED}[!] Error al enviar notificación Telegram${NORMAL}"
    fi
}

# ─────────────────────────────────────────
# PORT SCAN FUNCTION
# ─────────────────────────────────────────
port_scan() {
    local output=$1

    if ! command -v nmap &> /dev/null; then
        echo -e "${RED}[!] nmap no encontrado. Instala con: sudo apt install nmap${NORMAL}"
        return 1
    fi

    echo -e "${LCYAN}[*] Escaneando puertos (todos) en hosts activos...${NORMAL}"

    # Extract IPs/hosts from live.txt
    local hosts_file="$output/live_hosts_clean.txt"
    sed 's|https\?://||g' "$output/live.txt" | cut -d'/' -f1 | sort -u > "$hosts_file"

    local total_hosts=$(wc -l < "$hosts_file")
    echo -e "${GREEN}[+] Hosts a escanear: $total_hosts${NORMAL}"

    nmap -p- --open -T4 -iL "$hosts_file" \
        -oN "$output/ports.txt" \
        -oG "$output/ports_grep.txt" \
        2>/dev/null

    local open_ports=$(grep -c "open" "$output/ports.txt" 2>/dev/null || echo 0)
    echo -e "${GREEN}[✓] Puertos abiertos encontrados: $open_ports${NORMAL}"

    # Extract summary of open ports
    grep "open" "$output/ports.txt" | grep -v "#" > "$output/open_ports_summary.txt" 2>/dev/null

    [ "$TELEGRAM_ENABLED" = true ] && telegram_notify \
"🔍 *WebCopilot - Escaneo de Puertos*
🎯 Target: \`$TARGET\`
🖥️ Hosts escaneados: $total_hosts
🔓 Puertos abiertos: $open_ports"
}

# ─────────────────────────────────────────
# EXTENDED ENUMERATION FUNCTION
# ─────────────────────────────────────────
extended_enum() {
    local target=$1
    local output=$2

    echo -e "${LCYAN}[*] Enumeración extendida de URLs...${NORMAL}"

    # waybackurls
    if command -v waybackurls &> /dev/null; then
        echo -e "${GREEN}[+] Waybackurls...${NORMAL}"
        cat "$output/subs.txt" | waybackurls 2>/dev/null | sort -u >> "$output/urls.txt"
    else
        echo -e "${YELLOW}[!] waybackurls no encontrado. Instala: go install github.com/tomnomnom/waybackurls@latest${NORMAL}"
    fi

    # gau (Get All URLs)
    if command -v gau &> /dev/null; then
        echo -e "${GREEN}[+] GAU (Get All URLs)...${NORMAL}"
        cat "$output/subs.txt" | gau --threads 5 2>/dev/null | sort -u >> "$output/urls.txt"
    else
        echo -e "${YELLOW}[!] gau no encontrado. Instala: go install github.com/lc/gau/v2/cmd/gau@latest${NORMAL}"
    fi

    # katana (crawling)
    if command -v katana &> /dev/null; then
        echo -e "${GREEN}[+] Katana (crawl)...${NORMAL}"
        cat "$output/live.txt" | katana -silent 2>/dev/null | sort -u >> "$output/urls.txt"
    else
        echo -e "${YELLOW}[!] katana no encontrado. Instala: go install github.com/projectdiscovery/katana/cmd/katana@latest${NORMAL}"
    fi

    # gospider
    if command -v gospider &> /dev/null; then
        echo -e "${GREEN}[+] GoSpider...${NORMAL}"
        gospider -S "$output/live.txt" -t 5 -q 2>/dev/null | grep -oP 'https?://[^\s"]+' | sort -u >> "$output/urls.txt"
    else
        echo -e "${YELLOW}[!] gospider no encontrado. Instala: go install github.com/jaeles-project/gospider@latest${NORMAL}"
    fi

    # Deduplicate urls
    if [ -f "$output/urls.txt" ]; then
        sort -u "$output/urls.txt" -o "$output/urls.txt"
        local url_count=$(wc -l < "$output/urls.txt")
        echo -e "${GREEN}[✓] URLs únicas recolectadas: $url_count${NORMAL}"

        # Extract interesting params for later fuzzing
        grep -oP '\?[^#\s]+' "$output/urls.txt" | sort -u > "$output/params.txt" 2>/dev/null
        local param_count=$(wc -l < "$output/params.txt" 2>/dev/null || echo 0)
        echo -e "${GREEN}[✓] Parámetros únicos encontrados: $param_count${NORMAL}"
    else
        echo -e "${RED}[!] No se recolectaron URLs${NORMAL}"
    fi
}

# ─────────────────────────────────────────
# AI ANALYSIS FUNCTION
# ─────────────────────────────────────────
ai_analyze() {
    local target=$1
    local output=$2
    
    echo -e "${MAGENTA}[🤖] Iniciando análisis con IA...${NORMAL}"
    
    if command -v ollama &> /dev/null; then
        echo -e "${GREEN}[✓] Ollama disponible${NORMAL}"
        AI_MODEL="llama3.2"
    else
        echo -e "${YELLOW}[!] Sin IA - Ollama no disponible${NORMAL}"
        return 1
    fi
    
    local subs_count=$(wc -l < "$output/subs.txt" 2>/dev/null || echo 0)
    local live_count=$(wc -l < "$output/live.txt" 2>/dev/null || echo 0)
    local vuln_count=$(wc -l < "$output/nuclei.txt" 2>/dev/null || echo 0)
    local xss_count=$(wc -l < "$output/xss.txt" 2>/dev/null || echo 0)
    local url_count=$(wc -l < "$output/urls.txt" 2>/dev/null || echo 0)
    local port_count=$(wc -l < "$output/open_ports_summary.txt" 2>/dev/null || echo 0)

    local summary="Target: $target
Subdomains found: $subs_count
Live hosts: $live_count
Nuclei findings: $vuln_count
XSS findings: $xss_count
URLs collected: $url_count
Open ports: $port_count"
    
    echo -e "${MAGENTA}[🤖] Analizando resultados con IA...${NORMAL}"
    
    {
        echo "=== ANÁLISIS DE IA ==="
        echo "$summary"
        echo ""
        echo "Eres un experto en ciberseguridad. Analiza estos resultados de reconocimiento y sugiere:"
        echo "1. Las 3 vulnerabilidades más probables a probar"
        echo "2. Próximos pasos concretos"
        echo "Sé conciso y práctico."
    } | ollama run llama3.2 2>/dev/null
    
    echo -e "${GREEN}[✓] Análisis completado${NORMAL}"
}

# ─────────────────────────────────────────
# PARSE ARGUMENTS
# ─────────────────────────────────────────
TARGET=""
OUTPUT=""
FULLSCAN=false
AI_ENABLED=false
PORT_SCAN=false
TELEGRAM_ENABLED=true
TELEGRAM_TOKEN=8791036758:AAG1uLc4wDEmS49sjtYlSybeFwRVn4NyYFI
TELEGRAM_CHAT_ID=8791036758
THREADS=50

while getopts "d:o:at:hipnT:C:" opt; do
    case $opt in
        d) TARGET="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        a) FULLSCAN=true ;;
        t) THREADS="$OPTARG" ;;
        i) AI_ENABLED=true ;;
        p) PORT_SCAN=true ;;
        n) TELEGRAM_ENABLED=true ;;
        T) TELEGRAM_TOKEN="$OPTARG" ;;
        C) TELEGRAM_CHAT_ID="$OPTARG" ;;
        h) banner; usage ;;
    esac
done

[ -z "$TARGET" ] && { banner; echo "Error: -d required"; exit 1; }

# Allow token/chatid via env vars as fallback
[ -z "$TELEGRAM_TOKEN" ]   && TELEGRAM_TOKEN="${TG_TOKEN:-}"
[ -z "$TELEGRAM_CHAT_ID" ] && TELEGRAM_CHAT_ID="${TG_CHAT_ID:-}"

[ -z "$OUTPUT" ] && OUTPUT="webcopilot-$(date +%Y%m%d-%H%M%S)-${TARGET}"
mkdir -p "$OUTPUT" && cd "$OUTPUT"
OUTPUT_DIR="$(pwd)"

banner
echo -e "${GREEN}[+] Target:  $TARGET${NORMAL}"
echo -e "${GREEN}[+] Output:  $OUTPUT_DIR${NORMAL}"
[ "$AI_ENABLED" = true ]       && echo -e "${MAGENTA}[🤖] AI Analysis:      ENABLED${NORMAL}"
[ "$PORT_SCAN" = true ]        && echo -e "${LCYAN}[🔍] Port Scan:        ENABLED (all ports)${NORMAL}"
[ "$TELEGRAM_ENABLED" = true ] && echo -e "${YELLOW}[📬] Telegram Notify:  ENABLED${NORMAL}"
echo ""

# Notify scan start
[ "$TELEGRAM_ENABLED" = true ] && telegram_notify \
"🚀 *WebCopilot v${VERSION} - Scan Iniciado*
🎯 Target: \`$TARGET\`
⏰ $(date '+%Y-%m-%d %H:%M:%S')"

# ─────────────────────────────────────────
# 1. ENUMERATE SUBDOMAINS
# ─────────────────────────────────────────
echo -e "${LCYAN}[*] Enumerando subdominios...${NORMAL}"

echo -e "${GREEN}[+] Assetfinder...${NORMAL}"
echo "$TARGET" | assetfinder 2>/dev/null | sort -u >> subs.txt

echo -e "${GREEN}[+] Subfinder...${NORMAL}"
echo "$TARGET" | subfinder -silent 2>/dev/null | sort -u >> subs.txt

echo -e "${GREEN}[+] Amass...${NORMAL}"
amass enum -passive -d "$TARGET" 2>/dev/null | sort -u >> subs.txt

sort -u subs.txt -o subs.txt

if [ ! -s subs.txt ]; then
    echo -e "${RED}[!] No subdomains found${NORMAL}"
    exit 1
fi

TOTAL=$(wc -l < subs.txt)
echo -e "${GREEN}[✓] Encontrados: $TOTAL subdominios${NORMAL}\n"

[ "$TELEGRAM_ENABLED" = true ] && telegram_notify \
"📡 *Subdominios encontrados*
🎯 Target: \`$TARGET\`
🔢 Total: $TOTAL subdominios"

# ─────────────────────────────────────────
# 2. LIVE CHECK
# ─────────────────────────────────────────
echo -e "${LCYAN}[*] Verificando hosts activos...${NORMAL}"
cat subs.txt | ~/go/bin/httpx -threads $THREADS -silent 2>/dev/null > live.txt

if [ ! -s live.txt ]; then
    echo -e "${RED}[!] No live hosts found${NORMAL}"
    exit 1
fi

LIVE=$(wc -l < live.txt)
echo -e "${GREEN}[✓] Activos: $LIVE hosts${NORMAL}\n"

[ "$TELEGRAM_ENABLED" = true ] && telegram_notify \
"🟢 *Hosts Activos*
🎯 Target: \`$TARGET\`
🖥️ Live: $LIVE hosts"

# ─────────────────────────────────────────
# 3. EXTENDED URL ENUMERATION
# ─────────────────────────────────────────
extended_enum "$TARGET" "$OUTPUT_DIR"
URL_COUNT=$(wc -l < "$OUTPUT_DIR/urls.txt" 2>/dev/null || echo 0)

[ "$TELEGRAM_ENABLED" = true ] && [ "$URL_COUNT" -gt 0 ] && telegram_notify \
"🌐 *URLs Recolectadas*
🎯 Target: \`$TARGET\`
🔗 URLs únicas: $URL_COUNT"

# ─────────────────────────────────────────
# 4. PORT SCAN
# ─────────────────────────────────────────
if [ "$PORT_SCAN" = true ]; then
    echo ""
    port_scan "$OUTPUT_DIR"
fi

# ─────────────────────────────────────────
# 5. VULN SCAN
# ─────────────────────────────────────────
if [ "$FULLSCAN" = true ]; then
    echo -e "${LCYAN}[*] Escaneando vulnerabilidades...${NORMAL}"
    
    echo -e "${GREEN}[+] Nuclei...${NORMAL}"
    cat live.txt | ~/go/bin/nuclei -severity critical,high,medium -silent -nc 2>/dev/null > nuclei.txt
    
    echo -e "${GREEN}[+] Dalfox (XSS)...${NORMAL}"
    cat live.txt | dalfox pipe -o xss.txt 2>/dev/null
    
    NUCLEI_COUNT=$(wc -l < nuclei.txt 2>/dev/null || echo 0)
    XSS_COUNT=$(wc -l < xss.txt 2>/dev/null || echo 0)

    [ -f nuclei.txt ] && echo -e "${RED}[+] Nuclei:  $NUCLEI_COUNT findings${NORMAL}"
    [ -f xss.txt ]    && echo -e "${RED}[+] XSS:     $XSS_COUNT findings${NORMAL}"

    [ "$TELEGRAM_ENABLED" = true ] && telegram_notify \
"⚠️ *Vulnerabilidades Detectadas*
🎯 Target: \`$TARGET\`
🔴 Nuclei (critical/high/med): $NUCLEI_COUNT
💉 XSS: $XSS_COUNT"
fi

# ─────────────────────────────────────────
# 6. AI ANALYSIS
# ─────────────────────────────────────────
if [ "$AI_ENABLED" = true ]; then
    echo ""
    ai_analyze "$TARGET" "$OUTPUT_DIR"
fi

# ─────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════"
echo -e "${GREEN}[✓] DONE${NORMAL}"
echo "═══════════════════════════════════════"
echo "Output: $OUTPUT_DIR"
[ -f subs.txt ]               && echo "  📋 subs.txt                ($TOTAL)"
[ -f live.txt ]               && echo "  🟢 live.txt                ($LIVE)"
[ -f urls.txt ]               && echo "  🌐 urls.txt                ($URL_COUNT)"
[ -f params.txt ]             && echo "  🔧 params.txt              ($(wc -l < params.txt))"
[ -f ports.txt ]              && echo "  🔍 ports.txt               (nmap full)"
[ -f open_ports_summary.txt ] && echo "  🔓 open_ports_summary.txt  ($(wc -l < open_ports_summary.txt))"
[ -f nuclei.txt ]             && echo "  ⚠️  nuclei.txt              ($(wc -l < nuclei.txt))"
[ -f xss.txt ]                && echo "  💉 xss.txt                 ($(wc -l < xss.txt))"
echo ""

[ "$TELEGRAM_ENABLED" = true ] && telegram_notify \
"✅ *WebCopilot - Scan Completado*
🎯 Target: \`$TARGET\`
📋 Subdominios: $TOTAL
🟢 Hosts activos: $LIVE
🌐 URLs: $URL_COUNT
⏰ $(date '+%Y-%m-%d %H:%M:%S')"

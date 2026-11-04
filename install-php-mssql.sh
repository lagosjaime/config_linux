#!/usr/bin/env bash
# Instala en Fedora 44:
#   - PHP 8.5 (Remi) + Composer
#   - MySQL: pdo_mysql / mysqli (mysqlnd)
#   - MSSQL: unixODBC + Microsoft ODBC Driver 18 + pdo_sqlsrv + sqlsrv
#   - sqlcmd (mssql-tools18)
#
# Uso:
#   sudo bash /tmp/opencode/install-php-mssql.sh
#   sudo PHP_VER=84 bash /tmp/opencode/install-php-mssql.sh   # si se prefiere PHP 8.4
set -Eeuo pipefail

# Aceptación no interactiva de la licencia de los paquetes de Microsoft
export ACCEPT_EULA=Y

PHP_VER="${PHP_VER:-85}"          # 85 = PHP 8.5 | 84 = PHP 8.4
FEDORA_VER="$(rpm -E %fedora)"

BLUE=$'\e[1;34m'; RED=$'\e[1;31m'; OFF=$'\e[0m'
log() { printf '\n%s==> %s%s\n' "$BLUE" "$*" "$OFF"; }
die() { printf '\n%sERROR: %s%s\n' "$RED" "$*" "$OFF" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Ejecuta este script con sudo."
[[ "$FEDORA_VER" == "44" ]] || log "Aviso: script probado en Fedora 44 (detectado: $FEDORA_VER)."
command -v dnf >/dev/null || die "dnf no encontrado."

# ---------------------------------------------------------------- 1. Repo Remi
log "Configurando repositorio Remi (PHP ${PHP_VER})..."
if ! rpm -q remi-release >/dev/null 2>&1; then
  dnf install -y --nogpgcheck "https://rpms.remirepo.net/fedora/remi-release-${FEDORA_VER}.rpm"
fi
dnf config-manager setopt remi.enabled=1 >/dev/null

# ----------------------------------------------------------- 2. Repo Microsoft
log "Configurando repositorio de Microsoft (ODBC Driver 18 para SQL Server)..."
rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat >/etc/yum.repos.d/microsoft-prod.repo <<'EOF'
[packages-microsoft-com-prod]
name=Microsoft Production
baseurl=https://packages.microsoft.com/rhel/9/prod/
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
sslverify=1
EOF

# ------------------------------------------------------- 3. ODBC + sqlcmd
log "Instalando unixODBC, msodbcsql18 y mssql-tools18..."
dnf install -y unixODBC msodbcsql18 mssql-tools18

# ------------------------------------------------------------------- 4. PHP
log "Instalando PHP ${PHP_VER} y extensiones..."
PKGS=(
  "php${PHP_VER}-php-cli"
  "php${PHP_VER}-php-common"
  "php${PHP_VER}-php-fpm"
  "php${PHP_VER}-php-pdo"
  "php${PHP_VER}-php-mysqlnd"
  "php${PHP_VER}-php-sqlsrv"
  "php${PHP_VER}-php-odbc"
  "php${PHP_VER}-php-mbstring"
  "php${PHP_VER}-php-xml"
  "php${PHP_VER}-php-gd"
  "php${PHP_VER}-php-intl"
  "php${PHP_VER}-php-bcmath"
  "php${PHP_VER}-php-sodium"
  "php${PHP_VER}-php-devel"
  "php${PHP_VER}-php-pear"
  "php${PHP_VER}-php-pecl-zip"
)
dnf install -y "${PKGS[@]}"

# ------------------------------------------------- 5. 'php' como comando default
log "Configurando el comando 'php'..."
PHP_BIN="/usr/bin/php${PHP_VER}"
[[ -x "$PHP_BIN" ]] || die "No se encontró $PHP_BIN"
if command -v alternatives >/dev/null 2>&1; then
  alternatives --install /usr/bin/php php "$PHP_BIN" "${PHP_VER}" >/dev/null 2>&1 || true
  alternatives --set php "$PHP_BIN" >/dev/null 2>&1 || true
fi
if [[ ! -e /usr/bin/php ]]; then
  ln -sf "$PHP_BIN" /usr/local/bin/php
fi
hash -r

# -------------------------------------------------------------- 6. Composer
log "Instalando Composer en /usr/local/bin/composer..."
EXPECTED="$(curl -fsSL https://composer.github.io/installer.sig)"
curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php
ACTUAL="$("$PHP_BIN" -r "echo hash_file('sha384', '/tmp/composer-setup.php');")"
if [[ "$EXPECTED" != "$ACTUAL" ]]; then
  rm -f /tmp/composer-setup.php
  die "El checksum del instalador de Composer no coincide."
fi
"$PHP_BIN" /tmp/composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer
rm -f /tmp/composer-setup.php
chmod 755 /usr/local/bin/composer

# ------------------------------------------------ 7. sqlcmd en el PATH
cat >/etc/profile.d/mssql-tools18.sh <<'EOF'
export PATH="$PATH:/opt/mssql-tools18/bin"
EOF
chmod 644 /etc/profile.d/mssql-tools18.sh

# ------------------------------------------------------------ 8. Verificación
log "Verificación"
"$PHP_BIN" -v | head -n 2
/usr/local/bin/composer --version
printf '\nExtensiones PDO/DB cargadas:\n'
"$PHP_BIN" -m | grep -Ei 'pdo|mysql|sqlsrv|odbc' || true
printf '\nDrivers ODBC instalados:\n'
odbcinst -q -d || true
printf '\nVersión del driver SQL Server:\n'
odbcinst -q -d -n 'ODBC Driver 18 for SQL Server' 2>/dev/null || true
printf '\nsqlcmd:\n'
/opt/mssql-tools18/bin/sqlcmd -? 2>&1 | head -n 1 || true

log "Listo. Prueba de conexión (ejemplo):"
cat <<'EOF'
  php -r '$p = new PDO("sqlsrv:Server=HOST,1433;Database=DB;TrustServerCertificate=1", "usuario", "clave");'
EOF

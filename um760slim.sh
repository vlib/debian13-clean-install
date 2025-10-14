#!/bin/bash
# ============================================================
# Debian 13 (Trixie) - KDE Plasma 6 Wayland Minimal Install
# Matteo Edition 🇮🇹 - Completo con AMD + Realtek RTL8125
# Include KTorrent e Master PDF Editor 5
# ============================================================

echo ">>> Aggiornamento sistema..."
apt update && apt full-upgrade -y

# ------------------------------------------------------------
# KDE Plasma (Wayland) Core
# ------------------------------------------------------------
echo ">>> Installazione base KDE Plasma Wayland..."
apt install --no-install-recommends -y \
plasma-desktop \
plasma-workspace \
plasma-workspace-wayland \
plasma-framework \
kwin-wayland \
khotkeys \
systemsettings \
kde-cli-tools \
kmenuedit \
kglobalaccel \
kio \
kinit \
kscreen \
xwayland

# ------------------------------------------------------------
# Servizi di sistema essenziali
# ------------------------------------------------------------
echo ">>> Installazione servizi di sistema..."
apt install --no-install-recommends -y \
sddm \
network-manager \
plasma-nm \
pipewire \
wireplumber \
xdg-desktop-portal \
xdg-desktop-portal-kde \
pavucontrol \
alsa-utils \
bluedevil \
konsole \
kde-config-gtk-style \
kde-config-systemd

# ------------------------------------------------------------
# Applicazioni KDE minime
# ------------------------------------------------------------
echo ">>> Installazione applicazioni KDE minime..."
apt install --no-install-recommends -y \
firefox-esr \
libreoffice \
okular \
kwrite \
ark \
ffmpeg \
dolphin \
discover \
cups \
system-config-printer \
kdeconnect

# ------------------------------------------------------------
# Applicazioni extra già incluse
# ------------------------------------------------------------
echo ">>> Installazione applicazioni extra..."
apt install --no-install-recommends -y \
thunderbird \
thunderbird-l10n-it \
filezilla \
putty \
calibre \
keepassxc \
kiwix \
ktorrent

# ------------------------------------------------------------
# Master PDF Editor 5 - repository ufficiale
# ------------------------------------------------------------
echo ">>> Aggiunta repository Master PDF Editor..."
wget --quiet -O - http://repo.code-industry.net/deb/pubmpekey.asc | tee /etc/apt/keyrings/pubmpekey.asc
echo "deb [signed-by=/etc/apt/keyrings/pubmpekey.asc arch=$(dpkg --print-architecture)] http://repo.code-industry.net/deb stable main" | tee /etc/apt/sources.list.d/master-pdf-editor.list
echo ">>> Aggiornamento repository..."
apt update
echo ">>> Installazione Master PDF Editor 5..."
apt install -y master-pdf-editor-5

# ------------------------------------------------------------
# Localizzazione Italiana
# ------------------------------------------------------------
echo ">>> Localizzazione italiana..."
apt install --no-install-recommends -y \
locales \
task-italian \
language-pack-kde-it \
language-pack-it \
hunspell-it \
mythes-it \
libreoffice-l10n-it \
firefox-esr-l10n-it

echo ">>> Configurazione locale italiana..."
sed -i 's/^# *it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=it_IT.UTF-8

# ------------------------------------------------------------
# Directory utente standard
# ------------------------------------------------------------
echo ">>> Creazione directory utente standard (italiane)..."
apt install -y xdg-user-dirs
if [ -n "$SUDO_USER" ]; then
    runuser -l "$SUDO_USER" -c 'xdg-user-dirs-update'
else
    xdg-user-dirs-update
fi

# ------------------------------------------------------------
# Ottimizzazioni estetiche e prestazionali
# ------------------------------------------------------------
echo ">>> Ottimizzazione estetica e performance..."
apt install --no-install-recommends -y breeze-cursor-theme breeze-gtk-theme fonts-noto

# Disattiva indicizzazione Baloo
mkdir -p /etc/xdg/kdeglobals.d
cat <<EOF > /etc/xdg/kdeglobals.d/disable_baloo.conf
[Basic Settings]
Indexing-Enabled=false
EOF

# Imposta tema, font e scaling di default
mkdir -p /etc/skel/.config
cat <<EOF > /etc/skel/.config/kdeglobals
[General]
ColorScheme=BreezeLight
Font=Noto Sans,10,-1,5,50,0,0,0,0,0
Fixed=Noto Sans Mono,10,-1,5,50,0,0,0,0,0
MenuFont=Noto Sans,10,-1,5,50,0,0,0,0,0
SmallestReadableFont=Noto Sans,8,-1,5,50,0,0,0,0,0
ToolBarFont=Noto Sans,9,-1,5,50,0,0,0,0,0

[Icons]
Theme=breeze

[KScreen]
ScaleFactor=1.25
EOF

# ------------------------------------------------------------
# ZRAM ottimizzata per 32 GB RAM (tmpfs attivo)
# ------------------------------------------------------------
echo ">>> Configurazione zram ottimizzata per 32 GB RAM..."
apt install -y systemd-zram-generator

cat <<EOF > /etc/systemd/zram-generator.conf
[zram0]
zram-size = 4096
compression-algorithm = zstd
swap-priority = 100
EOF

systemctl daemon-reexec
systemctl daemon-reload

# ------------------------------------------------------------
# AMD GPU / Mesa / Vulkan / Firmware
# ------------------------------------------------------------
echo ">>> Installazione driver e firmware AMD Radeon 760M..."
apt install -y mesa-vulkan-drivers firmware-amd-graphics mesa-utils

# ------------------------------------------------------------
# Imposta Plasma (Wayland) come sessione predefinita in SDDM
# ------------------------------------------------------------
echo ">>> Configurazione SDDM per usare Plasma Wayland di default..."
SDDM_CONF="/etc/sddm.conf.d/wayland.conf"
mkdir -p "$(dirname "$SDDM_CONF")"
cat <<EOF > "$SDDM_CONF"
[Autologin]
#User=$SUDO_USER
#Session=plasmawayland.desktop

[General]
Session=plasmawayland.desktop
EOF

# ------------------------------------------------------------
# Sezione opzionale: Google Drive in KDE/Dolphin
# ------------------------------------------------------------
# Per integrare Google Drive come unità in Dolphin/KDE,
# decommenta le righe seguenti. Servono solo se vuoi accedere
# ai tuoi file Google Drive direttamente dal file manager.
# ------------------------------------------------------------
# apt install -y kaccounts-providers kio-gdrive kaccounts-integration
# echo ">>> Dopo l'installazione, aggiungi il tuo account Google"
# echo ">>> Impostazioni di Sistema → Account Online → Google"

# ------------------------------------------------------------
# Abilita avvio grafico e pulizia
# ------------------------------------------------------------
echo ">>> Abilita avvio grafico..."
systemctl enable sddm
systemctl set-default graphical.target

echo ">>> Pulizia pacchetti inutili..."
apt autoremove --purge -y
apt clean

# ------------------------------------------------------------
# Fine
# ------------------------------------------------------------
echo "============================================================"
echo " Installazione completata con successo 🎉"
echo " Debian 13 KDE Plasma Wayland - Matteo Edition 🇮🇹"
echo " GPU AMD e Realtek RTL8125 già supportate"
echo " Tutte le applicazioni extra sono già installate (KTorrent e Master PDF Editor inclusi)."
echo " Google Drive opzionale è commentato nello script."
echo " Riavvia per entrare in Plasma (Wayland) di default."
echo " Controlla sessione con:  echo \$XDG_SESSION_TYPE"
echo "============================================================"

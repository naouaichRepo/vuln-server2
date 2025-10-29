# =========================
# 🏗️ Étape 1 : Build
# =========================
FROM node:20@sha256:942fa0013e9adfbde06ad07433bdb0a67cc2ac0d5a3db38f12a9c8f710b41f1c AS builder

WORKDIR /usr/src/app

# Copier les fichiers de dépendances en premier pour profiter du cache Docker
COPY package.json package-lock.json* ./

# Installer toutes les dépendances (y compris dev)
RUN npm ci --production=false

# Copier le reste du code source
COPY . .

# Créer le dossier d’uploads attendu par l’app
RUN mkdir -p uploads

# =========================
# 🚀 Étape 2 : Runtime
# =========================
FROM node:20-slim@sha256:cba1d7bb8433bb920725193cd7d95d09688fb110b170406f7d4de948562f9850 AS runtime

# Installer uniquement les outils nécessaires à l’exécution
RUN apt-get update && apt-get install -y iputils-ping libcap2-bin && rm -rf /var/lib/apt/lists/*

# Créer un utilisateur non-root
RUN useradd -m nodeweb

WORKDIR /usr/src/app

# Copier uniquement les fichiers nécessaires depuis l’étape de build
COPY --from=builder /usr/src/app /usr/src/app

# Donner les droits de ping à nodeweb (CAP_NET_RAW)
RUN setcap cap_net_raw+ep /bin/ping

# Définir l’utilisateur non-root
USER nodeweb

# Exposer le port
EXPOSE 3000

# Commande par défaut
CMD ["node", "server.js"]
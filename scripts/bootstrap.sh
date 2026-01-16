#!/usr/bin/env bash
set -euo pipefail

echo "== Overleaf Bootstrap: instalando dependencias básicas =="

if command -v docker >/dev/null 2>&1; then
  echo "Docker ya instalado: $(docker --version)"
else
  echo "Docker no encontrado. Intentando instalar (requiere sudo)."
  if [ -f /etc/debian_version ]; then
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  else
    echo "No es una distribucion Debian/Ubuntu detectada. Por favor instale Docker manualmente: https://docs.docker.com/get-docker/"
    exit 1
  fi
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "La instalación de Docker falló o no está disponible en PATH." >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose no disponible: intentando instalar plugin docker-compose-plugin..."
  if [ -f /etc/debian_version ]; then
    sudo apt-get install -y docker-compose-plugin || true
  fi
fi

echo "Asegurando que el usuario pueda usar docker sin sudo..."
if groups $USER | grep -q docker; then
  echo "Usuario $USER ya pertenece al grupo docker"
else
  echo "Agregando $USER al grupo docker (se necesita re-login para aplicar)"
  sudo usermod -aG docker $USER || true
  echo "Después de reiniciar sesión, podrá ejecutar docker sin sudo."
fi

echo "Instalando utilidades: git, openssl (si falta)"
if ! command -v git >/dev/null 2>&1; then
  sudo apt-get install -y git
fi
if ! command -v openssl >/dev/null 2>&1; then
  sudo apt-get install -y openssl
fi

echo "Bootstrap completado. Revise SETUP.md para siguientes pasos."

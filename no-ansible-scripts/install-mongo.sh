#!/usr/bin/env bash
# Instala MongoDB + mongosh portable en /opt.
# Requiere ejecutarse una vez como root.
# Tras la instalación, cualquier usuario puede arrancarlo sin privilegios.
set -euo pipefail

# =============================================================================
MONGO_VERSION="8.0.9"
MONGOSH_VERSION="2.3.9"
INSTALL_DIR="/opt/mongodb"
DATA_DIR="/opt/mongodb-data"
LOG_DIR="/opt/mongodb-logs"
MONGO_PORT="27017"
# =============================================================================

ARCH="x86_64"
MONGO_TARBALL="mongodb-linux-${ARCH}-ubuntu2404-${MONGO_VERSION}.tgz"
MONGOSH_TARBALL="mongosh-${MONGOSH_VERSION}-linux-x64.tgz"
MONGO_URL="https://fastdl.mongodb.org/linux/${MONGO_TARBALL}"
MONGOSH_URL="https://downloads.mongodb.com/compass/${MONGOSH_TARBALL}"

[[ $EUID -ne 0 ]] && { echo "Ejecuta con sudo (solo esta vez)."; exit 1; }
command -v curl &>/dev/null || apt-get install -y curl -q

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

echo "Descargando MongoDB ${MONGO_VERSION}..."
curl -fL --progress-bar "${MONGO_URL}" -o "${TMP}/${MONGO_TARBALL}"

echo "Descargando mongosh ${MONGOSH_VERSION}..."
curl -fL --progress-bar "${MONGOSH_URL}" -o "${TMP}/${MONGOSH_TARBALL}"

echo "Instalando en ${INSTALL_DIR}..."
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}" "${DATA_DIR}" "${LOG_DIR}"
tar -xzf "${TMP}/${MONGO_TARBALL}"  -C "${INSTALL_DIR}" --strip-components=1
tar -xzf "${TMP}/${MONGOSH_TARBALL}" -C "${TMP}/mongosh" --strip-components=1 2>/dev/null || \
  { mkdir -p "${TMP}/mongosh"; tar -xzf "${TMP}/${MONGOSH_TARBALL}" -C "${TMP}/mongosh" --strip-components=1; }
cp "${TMP}/mongosh/bin/mongosh" "${INSTALL_DIR}/bin/"

chmod 755 "${INSTALL_DIR}" "${INSTALL_DIR}/bin"
chmod 777 "${DATA_DIR}" "${LOG_DIR}"

# Configuración
cat > "${INSTALL_DIR}/mongod.conf" <<EOF
storage:
  dbPath: ${DATA_DIR}

systemLog:
  destination: file
  path: ${LOG_DIR}/mongod.log
  logAppend: true

net:
  port: ${MONGO_PORT}
  bindIp: 127.0.0.1

processManagement:
  fork: true
  pidFilePath: ${LOG_DIR}/mongod.pid
EOF
chmod 644 "${INSTALL_DIR}/mongod.conf"

# Symlinks binarios
ln -sf "${INSTALL_DIR}/bin/mongod"  /usr/local/bin/mongod
ln -sf "${INSTALL_DIR}/bin/mongosh" /usr/local/bin/mongosh

# -----------------------------------------------------------------------------
# mongo-start
# -----------------------------------------------------------------------------
cat > /usr/local/bin/mongo-start <<EOF
#!/usr/bin/env bash
PID_FILE="${LOG_DIR}/mongod.pid"
PORT="${MONGO_PORT}"

if [[ -f "\$PID_FILE" ]] && kill -0 "\$(cat \$PID_FILE)" 2>/dev/null; then
  echo "MongoDB ya está corriendo (PID \$(cat \$PID_FILE), puerto \$PORT)"
  exit 0
fi

${INSTALL_DIR}/bin/mongod --config ${INSTALL_DIR}/mongod.conf

# Esperar a que arranque
for i in \$(seq 1 10); do
  sleep 0.5
  if [[ -f "\$PID_FILE" ]] && kill -0 "\$(cat \$PID_FILE)" 2>/dev/null; then
    echo "MongoDB iniciado."
    echo "  PID    : \$(cat \$PID_FILE)"
    echo "  Puerto : \$PORT"
    echo "  Datos  : ${DATA_DIR}"
    echo "  Log    : ${LOG_DIR}/mongod.log"
    echo ""
    echo "  Conectar: mongosh --port \$PORT"
    exit 0
  fi
done

echo "Error al arrancar. Revisa: ${LOG_DIR}/mongod.log"
exit 1
EOF
chmod 755 /usr/local/bin/mongo-start

# -----------------------------------------------------------------------------
# mongo-stop
# -----------------------------------------------------------------------------
cat > /usr/local/bin/mongo-stop <<EOF
#!/usr/bin/env bash
PID_FILE="${LOG_DIR}/mongod.pid"

if [[ ! -f "\$PID_FILE" ]]; then
  echo "MongoDB no está corriendo (PID file no encontrado)."
  exit 1
fi

PID=\$(cat "\$PID_FILE")
if ! kill -0 "\$PID" 2>/dev/null; then
  echo "El proceso \$PID no existe. Limpiando PID file."
  rm -f "\$PID_FILE"
  exit 1
fi

kill "\$PID"
echo "MongoDB detenido (PID \$PID)."
EOF
chmod 755 /usr/local/bin/mongo-stop

echo
echo "Instalación completada."
echo "  mongo-start   — arranca MongoDB"
echo "  mongo-stop    — detiene MongoDB"
echo "  mongosh --port ${MONGO_PORT}"
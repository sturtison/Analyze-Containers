#!/bin/bash
# (C) Copyright IBM Corporation 2018, 2020.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License 2.0 which is available at
# http://www.eclipse.org/legal/epl-2.0.
#
# SPDX-License-Identifier: EPL-2.0

set -e

. /opt/environment.sh

# Load secrets if they exist on disk and export them as envs
file_env 'DB_PASSWORD'
file_env 'DB_USERNAME'
file_env 'ZOO_DIGEST_PASSWORD'
file_env 'ZOO_DIGEST_USERNAME'
file_env 'SOLR_HTTP_BASIC_AUTH_USER'
file_env 'SOLR_HTTP_BASIC_AUTH_PASSWORD'

if [[ ${SOLR_ZOO_SSL_CONNECTION} == true ]]; then
  file_env 'SSL_PRIVATE_KEY'
  file_env 'SSL_CERTIFICATE'
  file_env 'SSL_CA_CERTIFICATE'
  if [[ -z ${SSL_PRIVATE_KEY} || -z ${SSL_CERTIFICATE} || -z ${SSL_CA_CERTIFICATE} ]]; then
    echo "Missing security environment variables. Please check SSL_PRIVATE_KEY SSL_CERTIFICATE SSL_CA_CERTIFICATE"
    exit 1
  fi
  TMP_SECRETS=/tmp/i2acerts
  KEY=${TMP_SECRETS}/server.key
  CER=${TMP_SECRETS}/server.cer
  CA_CER=${TMP_SECRETS}/CA.cer
  KEYSTORE=${TMP_SECRETS}/keystore.p12
  TRUSTSTORE=${TMP_SECRETS}/truststore.p12
  KEYSTORE_PASS=$(openssl rand -base64 16)
  export KEYSTORE_PASS

  mkdir ${TMP_SECRETS}
  echo "${SSL_PRIVATE_KEY}" >"${KEY}"
  echo "${SSL_CERTIFICATE}" >"${CER}"
  echo "${SSL_CA_CERTIFICATE}" >"${CA_CER}"

  openssl pkcs12 -export -in ${CER} -inkey "${KEY}" -certfile ${CA_CER} -passout env:KEYSTORE_PASS -out "${KEYSTORE}"
  OUTPUT=$(keytool -importcert -noprompt -alias ca -keystore "${TRUSTSTORE}" -file ${CA_CER} -storepass:env KEYSTORE_PASS -storetype PKCS12 2>&1)
    if [[ "$OUTPUT" != "Certificate was added to keystore" ]]; then
    echo "$OUTPUT"
    exit 1
  fi

  ZOO_SSL_KEY_STORE_LOCATION=${KEYSTORE}
  ZOO_SSL_TRUST_STORE_LOCATION=${TRUSTSTORE}
  ZOO_SSL_KEY_STORE_PASSWORD=${KEYSTORE_PASS}
  ZOO_SSL_TRUST_STORE_PASSWORD=${KEYSTORE_PASS}

  export ZOO_SSL_KEY_STORE_LOCATION
  export ZOO_SSL_TRUST_STORE_LOCATION
  export ZOO_SSL_KEY_STORE_PASSWORD
  export ZOO_SSL_TRUST_STORE_PASSWORD

else
  if [[ ${DB_SSL_CONNECTION} == true ]]; then
    file_env 'SSL_CA_CERTIFICATE'
    if [[ -z ${SSL_CA_CERTIFICATE} ]]; then
      echo "Missing security environment variables. Please check SSL_CA_CERTIFICATE"
      exit 1
    fi
    TMP_SECRETS=/tmp/i2acerts
    CA_CER=${TMP_SECRETS}/CA.cer
    TRUSTSTORE=${TMP_SECRETS}/truststore.p12
    KEYSTORE_PASS=$(openssl rand -base64 16)
    export KEYSTORE_PASS

    mkdir ${TMP_SECRETS}
    echo "${SSL_CA_CERTIFICATE}" >"${CA_CER}"

    keytool -importcert -noprompt -alias ca -keystore "${TRUSTSTORE}" -file ${CA_CER} -storepass:env KEYSTORE_PASS -storetype PKCS12
  fi
fi

if [[ ${DB_SSL_CONNECTION} == true ]]; then
  DB_TRUSTSTORE_LOCATION=${TRUSTSTORE}
  DB_TRUSTSTORE_PASSWORD=${KEYSTORE_PASS}

  export DB_TRUSTSTORE_LOCATION
  export DB_TRUSTSTORE_PASSWORD
fi

set +e
exec "$@"

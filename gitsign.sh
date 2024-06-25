#!/bin/bash

SA=/var/run/secrets/kubernetes.io/serviceaccount/

CA=${SA}/ca.crt
TOKEN=$(cat ${SA}/token)
NS=$(cat ${SA}/namespace)
#KURL=https://kubernetes.default.svc

#curl --cacert ${CA} -H  "Authorization: Bearer ${TOKEN}" ${KURL}/api/v1/namespaces/${NS}/pods/
#/openapi/v2

PUBLIC_DOMAIN=${CLUSTER_CONSOLE_URL/*-console./}
PRIVATE_DOMAIN='svc.cluster.local'
TUF_URL="http://tuf.rhtap.${PRIVATE_DOMAIN}"
TUF_ROOT="${TUF_URL}/root.json"
REKOR_URL="http://rekor-server.rhtap.${PRIVATE_DOMAIN}"
FULCIO_URL="http://fulcio-server.rhtap.${PRIVATE_DOMAIN}"
KEYCLOAK_URL="https://keycloak-keycloak-system.${PUBLIC_DOMAIN}"

cosign initialize --mirror $TUF_URL --root $TUF_ROOT
gitsign initialize --mirror $TUF_URL --root $TUF_ROOT
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global gpg.x509.program gitsign
git config --global gpg.format x509

OPENSHIFT_APPS_SUBDOMAIN=$PUBLIC_DOMAIN

export OIDC_AUTHENTICATION_REALM=trusted-artifact-signer
export FULCIO_URL=https://fulcio-server-rhtap.$OPENSHIFT_APPS_SUBDOMAIN
export OIDC_ISSUER_URL=https://keycloak-keycloak-system.$OPENSHIFT_APPS_SUBDOMAIN/auth/realms/$OIDC_AUTHENTICATION_REALM
export REKOR_URL=https://rekor-server-rhtap.$OPENSHIFT_APPS_SUBDOMAIN
export TUF_URL=https://tuf.$OPENSHIFT_APPS_SUBDOMAIN

git config --global gitsign.fulcio $FULCIO_URL
git config --global gitsign.clientID $OIDC_AUTHENTICATION_REALM
git config --global gitsign.issuer $OIDC_ISSUER_URL
git config --global gitsign.matchCommitter true
git config --global gitsign.rekor $REKOR_URL
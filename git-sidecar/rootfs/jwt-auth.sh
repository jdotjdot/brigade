#!/usr/bin/env bash

# Inspired by implementation by Will Haley at:
#   http://willhaley.com/blog/generate-jwt-with-bash/
# Borrowed from https://stackoverflow.com/questions/46657001/how-do-you-create-an-rs256-jwt-assertion-with-bash-shell-scripting

set -o pipefail

build_header() {
  local header_template='{
    "typ": "JWT"
  }'

  jq -c \
        --arg iat_str "$(date +%s)" \
        --arg alg "${1:-HS256}" \
  '
  ($iat_str | tonumber) as $iat
  | .alg = $alg
  | .iat = $iat
  | .exp = ($iat + 1)
  ' <<<"$header_template" | tr -d '\n'
}

build_payload() {
  jq -c --arg iat_str "$(date +%s)" \
  '
  ($iat_str | tonumber) as $iat
  | .iat = $iat
  | .exp = ($iat + 600)
  ' <<<"$1" | tr -d '\n'
}

b64enc() { openssl enc -base64 -A | tr '+/' '-_' | tr -d '='; }
json() { jq -c . | LC_CTYPE=C tr -d '\n'; }
hs_sign() { openssl dgst -binary -sha"${1}" -hmac "$2"; }
rs_sign() { openssl dgst -binary -sha"${1}" -sign <(printf '%s\n' "$2"); }

sign() {
        local algo payload header sig secret=$3
        algo=${1:-RS256}
        header=$(build_header "$algo") || return
      	payload=$(build_payload "$2")
        signed_content="$(json <<<"$header" | b64enc).$(json <<<"$payload" | b64enc)"
        case $algo in
                HS*) sig=$(printf %s "$signed_content" | hs_sign "${algo#HS}" "$secret" | b64enc) ;;
                RS*) sig=$(printf %s "$signed_content" | rs_sign "${algo#RS}" "$secret" | b64enc) ;;
                *) echo "Unknown algorithm" >&2; return 1 ;;
        esac
        printf '%s.%s\n' "${signed_content}" "${sig}"
}

(( $# )) && sign "$@"

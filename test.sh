#!/bin/sh

set -euf

SEED="${SEED:-"$(date '+%s')"}"
DO_SH="${DO_SH:-}"
DO_SH_OPTS="${DO_SH_OPTS:-}"

echo() {
  printf '%s\n' "$*"
}
die() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

cd -- "$(dirname -- "$0")"

totp_sh() {
  $DO_SH $DO_SH_OPTS ./totp ${1+"$@"}
}

totp_py() {
  ./totp.py ${1+"$@"}
}

echo "[TEST] SEED=${SEED}"
echo "[TEST] DO_SH=${DO_SH}"
echo "[TEST] DO_SH_OPTS=${DO_SH_OPTS}"
echo "[TEST] ... TESTING ..."

secret="$(printf '%s' 'base32-decoded secret' | base32)"

[ 846121 = "$(printf '%s' "${secret}" | totp_py 30 2145916800)" ]
[ 846121 = "$(printf '%s' "${secret}" | totp_sh GitHub 30 2145916800)" ]


# PCG Random Number Generation ported to POSIX shell {
#
# Notice from original implementation in the C programming language:
#
# Copyright 2014-2019 Melissa O'Neill <oneill@pcg-random.org>,
#                     and the PCG Project contributors.
#
# Licensed under the Apache License, Version 2.0 (provided in
# LICENSE-APACHE.txt and at http://www.apache.org/licenses/LICENSE-2.0)
# or under the MIT license (provided in LICENSE-MIT.txt and at
# http://opensource.org/licenses/MIT), at your option. This code may not
# be copied, modified, or distributed except according to those terms.
#
# Distributed on an "AS IS" BASIS, WITHOUT WARRANTY OF ANY KIND, either
# express or implied.  See your chosen license for details.
#
# For additional information about the PCG random number generation scheme,
# visit http://www.pcg-random.org/.
if [ '#-9223372036854775808' = "#$(( 9223372036854775807 + 1 ))" ]; then
pcg64si_srandom_r() {
  set -- "$(( $1 ))" 6364136223846793005 1442695040888963407
  pcg_state="$(( (0 * $2 + $3 + $1) * $2 + $3 ))" pcg_max=9223372036854775807
}
pcg64si_random_r() {
  set -- "${pcg_state}" "$(( (pcg_state >> 1) & pcg_max ))"
  pcg_state="$(( pcg_state * 6364136223846793005 + 1442695040888963407 ))"
  pcg_number="$(( (($2 >> (($2 >> 58) + 4)) ^ $1) * -5840758589994634535 ))"
  pcg_number="$(( (((pcg_number >> 1) & pcg_max) >> 42) ^ pcg_number ))"
}
pcg_srand() {
  pcg64si_srandom_r "$1"
}
pcg_rand() {
  # TODO: send patches to http://gondor.apana.org.au/~herbert/dash/
  # XXX(dash): -9223372036854775807 <= $(( -9223372036854775808 ))
  # XXX(dash): -9223372036854775808 <= $(( x )) # x='-9223372036854775808'
  if [ 0 -lt "$#" ]; then  # [0, 2^63 - 1] when $1=-9223372036854775808
    # https://www.pcg-random.org/posts/bounded-rands.html
    set -- "$(( $1 ))"; set -- "$1" "$(( (pcg_max % $1 + 1 % $1) % $1 ))"
    while true; do
      pcg64si_random_r
      pcg_number="$(( pcg_number < 0 ? pcg_max - ~pcg_number : pcg_number ))"
      if [ "$2" -le "${pcg_number}" ]; then
        pcg_number="$(( pcg_number % $1 ))"
        break
      fi
    done
  else
    pcg64si_random_r  # [0 - 2^63, 2^63 - 1] <=> [0, 2^64 - 1]
  fi
}
elif [ '#-2147483648' = "#$(( 2147483647 + 1 ))" ]; then
pcg32si_srandom_r() {
  set -- "$(( $1 ))" 747796405 2891336453
  pcg_state="$(( (0 * $2 + $3 + $1) * $2 + $3 ))" pcg_max=2147483647
}
pcg32si_random_r() {
  set -- "${pcg_state}" "$(( (pcg_state >> 1) & pcg_max ))"
  pcg_state="$(( pcg_state * 747796405 + 2891336453 ))"
  pcg_number="$(( (($2 >> (($2 >> 27) + 3)) ^ $1) * 277803737 ))"
  pcg_number="$(( (((pcg_number >> 1) & pcg_max) >> 21) ^ pcg_number ))"
}
pcg_srand() {
  pcg32si_srandom_r "$1"
}
pcg_rand() {
  if [ 0 -lt "$#" ]; then  # [0, 2^31 - 1] when $1=-2147483648
    set -- "$(( $1 ))"; set -- "$1" "$(( (pcg_max % $1 + 1 % $1) % $1 ))"
    while true; do
      pcg32si_random_r
      pcg_number="$(( pcg_number < 0 ? pcg_max - ~pcg_number : pcg_number ))"
      if [ "$2" -le "${pcg_number}" ]; then
        pcg_number="$(( pcg_number % $1 ))"
        break
      fi
    done
  else
    pcg32si_random_r  # [0 - 2^31, 2^31 - 1] <=> [0, 2^32 - 1]
  fi
}
else  # just a hack for testing with ksh
pcg_srand() {
  RANDOM="$1"
}
pcg_rand() {
  # shellcheck disable=SC2039,SC3028
  pcg_number="${RANDOM}"
}
fi
pcg_clear() {
  unset -v pcg_state pcg_number pcg_max
}
pcg_clear
# PCG Random Number Generation ported to POSIX shell }


pcg_srand "${SEED}"
i=100
while [ 0 -le "$(( i -= 1 ))" ]; do
  pcg_rand 2147483647; secret="$(printf '%s' "${pcg_number}" | base32)"
  pcg_rand 2147483647; interval="${pcg_number}"
  pcg_rand 2147483647; now="${pcg_number}"
  answer1="$(printf '%s' "${secret}" | totp_py "${interval}" "${now}")"
  answer2="$(printf '%s' "${secret}" | totp_sh Google "${interval}" "${now}")"
  [ x"${answer1}" = x"${answer2}" ] || die "LOOP#${i}"
done

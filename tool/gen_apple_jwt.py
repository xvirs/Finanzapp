#!/usr/bin/env python3
"""
Genera el client_secret JWT para Sign in with Apple (Supabase Auth
Provider).

Apple firma este JWT con la private key (.p8) descargada de
developer.apple.com → Keys. El JWT vive 6 meses (máximo permitido por
Apple) y hay que regenerarlo antes de que expire — sino los logins
dejan de funcionar.

Uso:
    pip3 install pyjwt cryptography  # primera vez
    python3 tool/gen_apple_jwt.py /ruta/a/AuthKey_37KSJVA598.p8

El script printea el JWT al stdout — copialo y pegalo en
Supabase → Auth → Providers → Apple → Secret Key (for OAuth).
"""

import sys
import time

import jwt  # pyjwt

# Datos fijos del proyecto Finanzapp.
TEAM_ID = "SJVXS34P6P"
KEY_ID = "37KSJVA598"
SERVICE_ID = "app.finanzapp.client.auth"
VALIDITY_DAYS = 180  # ~6 meses, máx permitido por Apple


def main():
    if len(sys.argv) < 2:
        print("Uso: python3 tool/gen_apple_jwt.py /ruta/a/AuthKey_XXX.p8")
        sys.exit(1)

    p8_path = sys.argv[1]
    with open(p8_path, "r") as f:
        private_key = f.read()

    now = int(time.time())
    exp = now + (60 * 60 * 24 * VALIDITY_DAYS)

    headers = {"kid": KEY_ID, "alg": "ES256"}
    payload = {
        "iss": TEAM_ID,
        "iat": now,
        "exp": exp,
        "aud": "https://appleid.apple.com",
        "sub": SERVICE_ID,
    }

    client_secret = jwt.encode(
        payload=payload,
        key=private_key,
        algorithm="ES256",
        headers=headers,
    )

    print()
    print("=" * 60)
    print("APPLE SIGN-IN CLIENT SECRET (JWT)")
    print("=" * 60)
    print(client_secret)
    print("=" * 60)
    print()
    expires = time.strftime("%Y-%m-%d", time.localtime(exp))
    print(f"Válido hasta: {expires}")
    print(
        "Pegalo en Supabase → Auth → Providers → Apple → "
        "Secret Key (for OAuth) → Save."
    )
    print()
    print(
        "⚠️  Reminder: regenerá este JWT antes de la fecha de expiración. "
        "Cuando expira, los logins de Apple Sign-In dejan de funcionar."
    )
    print()


if __name__ == "__main__":
    main()

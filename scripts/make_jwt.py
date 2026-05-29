#!/usr/bin/env python3
"""Create a local HS256 JWT for PostgREST development."""

from __future__ import annotations

import argparse
import base64
import hashlib
import hmac
import json
import os
import time


def _base64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def make_jwt(secret: str, tenant_id: str, role: str, expires_in: int) -> str:
    now = int(time.time())
    header = {"alg": "HS256", "typ": "JWT"}
    payload = {
        "role": role,
        "tenant_id": tenant_id,
        "iat": now,
        "exp": now + expires_in,
    }

    signing_input = ".".join(
        [
            _base64url(json.dumps(header, separators=(",", ":")).encode("utf-8")),
            _base64url(json.dumps(payload, separators=(",", ":")).encode("utf-8")),
        ]
    )
    signature = hmac.new(
        secret.encode("utf-8"),
        signing_input.encode("ascii"),
        hashlib.sha256,
    ).digest()
    return f"{signing_input}.{_base64url(signature)}"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--secret",
        default=os.environ.get("PGRST_JWT_SECRET"),
        help="PostgREST JWT secret. Defaults to PGRST_JWT_SECRET.",
    )
    parser.add_argument(
        "--tenant-id",
        default="00000000-0000-0000-0000-000000000001",
        help="Tenant UUID to place in the tenant_id claim.",
    )
    parser.add_argument("--role", default="authenticated", help="PostgREST database role claim.")
    parser.add_argument("--expires-in", type=int, default=86400, help="Token lifetime in seconds.")
    args = parser.parse_args()

    if not args.secret:
        parser.error("--secret or PGRST_JWT_SECRET is required")
    if len(args.secret) < 32:
        parser.error("PostgREST JWT secret should be at least 32 characters")

    print(make_jwt(args.secret, args.tenant_id, args.role, args.expires_in))


if __name__ == "__main__":
    main()

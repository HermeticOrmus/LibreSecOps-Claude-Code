# MFA Implementation

> MFA methods, integration patterns, bypass prevention, and phishing-resistant authentication.

## Knowledge Base

### MFA Factor Categories

Authentication factors fall into three categories (something you know, have, are):

| Category | Examples | Strength | Attack Vectors |
|----------|----------|----------|----------------|
| **Knowledge** (something you know) | Password, PIN, security questions | Weakest alone | Phishing, credential stuffing, brute force, social engineering |
| **Possession** (something you have) | TOTP app, hardware key, phone, smart card | Strong | Theft, SIM swap (SMS), real-time phishing relay |
| **Inherence** (something you are) | Fingerprint, face recognition, voice | Strong (local) | Biometric spoofing, coercion, liveness detection bypass |

True MFA requires factors from at least two different categories. Password + security questions is NOT MFA (both are knowledge). Password + TOTP IS MFA (knowledge + possession).

### MFA Method Comparison

| Method | Phishing Resistant | User Experience | Implementation Complexity | Cost |
|--------|-------------------|-----------------|--------------------------|------|
| **FIDO2/WebAuthn** (hardware key, passkey) | YES -- origin-bound | Excellent (tap key or biometric) | Medium | $20-70/key |
| **Passkeys** (synced WebAuthn) | YES -- origin-bound | Excellent (biometric on device) | Medium | Free |
| **TOTP** (Google Authenticator, Authy) | No -- code can be phished in real-time | Good | Low | Free |
| **Push notification** (Duo, MS Authenticator) | Partial -- MFA fatigue attacks | Good (approve/deny) | Medium | Per-user cost |
| **SMS OTP** | No -- SIM swap, SS7 intercept | Acceptable | Low | Per-SMS cost |
| **Email OTP** | No -- email compromise = MFA bypass | Acceptable | Low | Free |

### NIST Authenticator Assurance Levels (AAL)

| Level | Requirements | Use Case |
|-------|-------------|----------|
| **AAL1** | Single factor (password alone acceptable) | Low-sensitivity systems |
| **AAL2** | Multi-factor required. Software or hardware authenticator. | Most enterprise applications |
| **AAL3** | Multi-factor with hardware cryptographic authenticator (FIDO2). Verifier impersonation resistance required. | High-security: financial, healthcare, government |

## Patterns

### Pattern 1: WebAuthn/FIDO2 Registration Flow

```javascript
// Server-side: Generate registration options
async function generateRegistrationOptions(user) {
  const options = {
    challenge: crypto.randomBytes(32),  // Cryptographically random
    rp: {
      name: "My Application",
      id: "app.example.com"  // Origin-binding: key only works on this domain
    },
    user: {
      id: user.id,          // Unique, opaque user identifier
      name: user.email,
      displayName: user.name
    },
    pubKeyCredParams: [
      { type: "public-key", alg: -7 },   // ES256 (P-256)
      { type: "public-key", alg: -257 }  // RS256 (RSA)
    ],
    authenticatorSelection: {
      authenticatorAttachment: "cross-platform",  // Hardware key
      // OR "platform" for passkeys (Touch ID, Windows Hello)
      residentKey: "preferred",
      userVerification: "required"  // Require PIN/biometric on the key
    },
    timeout: 60000,
    attestation: "none"  // "direct" if you need to verify key manufacturer
  };

  // Store challenge for verification
  await storeChallenge(user.id, options.challenge);
  return options;
}

// Server-side: Verify registration response
async function verifyRegistration(user, credential) {
  const storedChallenge = await getChallenge(user.id);

  // Verify challenge matches (prevents replay)
  // Verify origin matches rp.id (prevents phishing)
  // Extract and store the public key and credential ID

  const verified = await verifyRegistrationResponse({
    response: credential,
    expectedChallenge: storedChallenge,
    expectedOrigin: "https://app.example.com",
    expectedRPID: "app.example.com",
  });

  if (verified) {
    await storeCredential(user.id, {
      credentialId: verified.credentialID,
      publicKey: verified.credentialPublicKey,
      counter: verified.counter,  // Sign count for cloning detection
    });
  }
}
```

**Why this works**: WebAuthn is phishing-resistant by design. The credential is cryptographically bound to the origin (domain) during registration. If a user visits a phishing site at `evil.example.com`, the authenticator will not find any credential for that origin and will not respond. This is not a user decision -- it is enforced by the protocol. Real-time phishing relays cannot bypass this because the challenge-response is origin-specific.

### Pattern 2: TOTP Implementation

```python
import pyotp
import qrcode
import io

# Registration: Generate and store secret
def setup_totp(user):
    """Generate a TOTP secret and provisioning URI."""
    secret = pyotp.random_base32()  # 32 characters of base32

    # Store the secret encrypted in the database
    # NEVER store in plaintext -- this IS the second factor
    store_encrypted_totp_secret(user.id, secret)

    # Generate provisioning URI for QR code
    totp = pyotp.TOTP(secret)
    provisioning_uri = totp.provisioning_uri(
        name=user.email,
        issuer_name="MyApp"
    )

    # Generate recovery codes (one-time use backup codes)
    recovery_codes = [pyotp.random_base32()[:8] for _ in range(10)]
    store_recovery_codes(user.id, hash_codes(recovery_codes))

    return provisioning_uri, recovery_codes

# Verification: Validate TOTP code
def verify_totp(user, code):
    """Verify a TOTP code with clock skew tolerance."""
    secret = decrypt_totp_secret(user.id)
    totp = pyotp.TOTP(secret)

    # valid_window=1 allows +/- 30 seconds (one time step)
    if totp.verify(code, valid_window=1):
        # Prevent replay: check if this code was already used
        if is_code_already_used(user.id, code):
            log_auth_event(user.id, "totp_replay_attempt")
            return False

        mark_code_as_used(user.id, code, ttl=90)  # TTL covers the window
        log_auth_event(user.id, "totp_success")
        return True

    # Check recovery codes as fallback
    if verify_recovery_code(user.id, code):
        log_auth_event(user.id, "recovery_code_used")
        return True

    log_auth_event(user.id, "totp_failure")
    return False
```

**Why this works**: TOTP secrets are stored encrypted (they are the equivalent of a private key). Clock skew tolerance of +/- 1 window (30 seconds) balances usability with security. Replay prevention ensures the same code cannot be used twice within its validity window. Recovery codes provide backup access if the authenticator is lost.

### Pattern 3: MFA Enforcement Middleware

```python
from functools import wraps
from datetime import datetime, timedelta

# MFA-required resources
MFA_REQUIRED_PATHS = [
    "/admin/*",
    "/api/users/*/delete",
    "/api/settings/*",
    "/api/billing/*",
]

# Step-up authentication for sensitive operations
MFA_STEP_UP_PATHS = [
    "/api/password/change",
    "/api/mfa/disable",
    "/api/export/data",
]

STEP_UP_VALIDITY = timedelta(minutes=5)

def mfa_middleware(request):
    """Enforce MFA at the application level."""

    # Check if path requires MFA
    if not matches_any_path(request.path, MFA_REQUIRED_PATHS + MFA_STEP_UP_PATHS):
        return None  # No MFA required for this path

    user = get_authenticated_user(request)

    # Check if user has completed MFA for this session
    if not user.session.mfa_completed:
        return redirect_to_mfa_challenge(request)

    # Check if path requires step-up (recent) MFA
    if matches_any_path(request.path, MFA_STEP_UP_PATHS):
        mfa_age = datetime.utcnow() - user.session.mfa_completed_at
        if mfa_age > STEP_UP_VALIDITY:
            return redirect_to_mfa_challenge(request, step_up=True)

    return None  # MFA satisfied
```

**Why this works**: MFA is enforced at the middleware level (not per-endpoint), ensuring consistent enforcement. Step-up authentication requires recent MFA for sensitive operations even if the session was MFA-authenticated earlier. This prevents a stolen MFA-authenticated session from being used for privilege escalation hours later.

## Anti-Patterns

### Anti-Pattern 1: SMS-Based MFA as Primary Method

SMS OTP is vulnerable to:
- **SIM swap attacks**: Attacker convinces carrier to transfer phone number
- **SS7 protocol attacks**: Intercept SMS messages via telecom network vulnerabilities
- **Real-time phishing**: Attacker proxies the SMS code through a phishing site
- **Social engineering**: Carrier employee tricked into redirecting messages

NIST SP 800-63B restricts SMS to AAL1 (lowest assurance) and recommends against it. Use TOTP at minimum, FIDO2/passkeys for high-security.

### Anti-Pattern 2: MFA Prompt Bombing (Fatigue Attacks)

Repeatedly triggering push notifications until the user approves one out of frustration (or accidentally). This led to the 2022 Uber breach.

**Fix**: Implement number matching (user must enter a code shown on screen into the authenticator app), rate limit MFA prompts, alert on unusual MFA volumes, and prefer FIDO2 which does not have this vulnerability.

### Anti-Pattern 3: Recoverable MFA Secrets

Allowing MFA to be reset via email, support call, or security questions without additional verification. If the first factor (password) is compromised, and MFA can be reset with just the email, MFA provides no additional security.

**Fix**: MFA reset should require identity verification (in-person, video call, or a separate out-of-band channel verified by management). Recovery codes generated at MFA enrollment provide a self-service fallback.

### Anti-Pattern 4: MFA Only at Login

Authenticating with MFA once at login and then granting unlimited session access for hours or days. An attacker who steals the session token (XSS, session hijacking) bypasses MFA entirely.

**Fix**: Implement step-up authentication for sensitive operations. Re-verify MFA before password changes, admin actions, financial transactions, and data exports.

### Anti-Pattern 5: Excluding Service Accounts from MFA

Service accounts often have powerful permissions but no MFA requirement. If a service account credential is stolen, there is no second factor to prevent access.

**Fix**: Service accounts should not use password authentication at all. Use managed identities, mTLS certificates, or Workload Identity Federation. If API keys are necessary, bind them to IP addresses and rotate them automatically.

## References

- [NIST SP 800-63B: Authentication and Lifecycle Management](https://pages.nist.gov/800-63-3/sp800-63b.html)
- [WebAuthn Specification](https://www.w3.org/TR/webauthn-2/)
- [FIDO Alliance](https://fidoalliance.org/)
- [Passkeys Developer Documentation](https://passkeys.dev/)
- [OWASP MFA Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Multifactor_Authentication_Cheat_Sheet.html)
- [SimpleWebAuthn (JavaScript Library)](https://simplewebauthn.dev/)
- [py_webauthn (Python Library)](https://github.com/duo-labs/py_webauthn)
- [Yubico Developer Documentation](https://developers.yubico.com/)

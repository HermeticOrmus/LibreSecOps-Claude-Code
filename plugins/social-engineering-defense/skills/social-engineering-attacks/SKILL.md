# Social Engineering Attacks

> Comprehensive taxonomy of social engineering attack types with psychological mechanisms, technical indicators, real-world case studies, and detection patterns.

## Knowledge Base

### Attack Categories

Social engineering attacks can be categorized by delivery channel, targeting level, and objective.

**By delivery channel**:

| Channel | Attack Types | Scale | Detection Difficulty |
|---------|-------------|-------|---------------------|
| Email | Phishing, spear phishing, BEC, lateral phishing | Mass to targeted | Low to High |
| Voice | Vishing, callback scams, deepfake calls | Targeted | High |
| SMS/Messaging | Smishing, WhatsApp/Signal phishing, MFA interception | Mass to targeted | Medium |
| Web | Watering hole, malvertising, fake login pages | Mass to targeted | Medium |
| Physical | Tailgating, impersonation, USB drops, dumpster diving | Targeted | High |
| Social media | Profile impersonation, romance scams, fake recruiters | Targeted | High |

**By targeting level**:

| Level | Name | Characteristics | Example |
|-------|------|----------------|---------|
| 0 | Spray and pray | No targeting, generic, volume-based | "Dear user, your account has been locked" |
| 1 | Industry targeting | Same template sent to a specific industry | Fake invoice to accounting departments |
| 2 | Organization targeting | Customized for a specific company | Email spoofing the company's IT department |
| 3 | Role targeting | Tailored to a specific role within the org | Fake wire transfer request to CFO |
| 4 | Individual targeting | Deeply researched, personal details | References actual projects, colleagues, events |
| 5 | Multi-channel | Combined email + phone + physical | Email + follow-up call + fake badge |

### Detailed Attack Profiles

**Business Email Compromise (BEC) -- FBI IC3 most costly cybercrime category**

BEC is not traditional phishing. It rarely uses malware or malicious links. Instead, it manipulates business processes through impersonation and authority.

Variants:
1. **CEO fraud**: Attacker impersonates CEO, emails finance requesting urgent wire transfer
2. **Invoice manipulation**: Attacker compromises vendor email, sends legitimate-looking invoice with changed bank details
3. **Account compromise**: Attacker compromises an employee's actual email and uses it to send requests to contacts
4. **Attorney impersonation**: Attacker impersonates lawyer handling confidential matter requiring urgent payment
5. **Data theft**: Attacker impersonates HR executive requesting W-2 forms or employee PII

Indicators:
- Reply-to address differs from display name
- Unusual urgency for financial transactions
- Request to change payment details for existing vendor
- "Keep this confidential" language designed to prevent verification
- Timing aligned with executive travel or known absences
- Email thread forwarding with subtle changes to recipient list

**Adversary-in-the-Middle (AiTM) Phishing**

Modern phishing that defeats MFA by proxying the authentication in real-time.

Mechanism:
1. Victim receives phishing email with link to attacker-controlled proxy
2. Proxy presents the real login page (Microsoft 365, Google Workspace)
3. Victim enters credentials and MFA code
4. Proxy captures session cookie after successful authentication
5. Attacker uses stolen session cookie -- MFA already satisfied

Tools used by attackers: Evilginx2, Modlishka, Muraena

Defense: FIDO2/WebAuthn hardware keys (phishing-resistant MFA), conditional access policies based on device compliance, token binding

**Callback Phishing (BazarCall / BazaCall)**

Combines email and voice:
1. Victim receives email about a fake subscription/charge
2. Email contains a phone number to "cancel" -- no malicious link
3. Victim calls the number (bypasses email security controls)
4. Attacker guides victim to download remote access tool or malicious document
5. Attacker gains access to the victim's system

This technique evades email security because the email contains no links, no attachments, and no malware.

**QR Code Phishing (Quishing)**

Uses QR codes to bypass email URL scanning:
1. Phishing email contains a QR code image instead of a clickable link
2. Email security tools do not scan URLs embedded in images
3. Victim scans QR code with phone (bypasses corporate network controls)
4. Phone browser opens credential harvesting page
5. Corporate MFA codes entered on personal device

**Deepfake Social Engineering**

AI-generated audio or video used for impersonation:
- Voice cloning: 3 seconds of audio can generate a convincing voice clone
- Video deepfake: Real-time video manipulation for video call impersonation
- Use cases: CEO voice requesting wire transfer, IT support impersonation
- Case study: 2024 $25M fraud against multinational using deepfake video of CFO in video call

### Psychological Mechanisms in Detail

**Authority pressure**: The attacker positions themselves as someone the target is conditioned to obey (CEO, IT admin, government official, law enforcement). The target's decision-making shifts from "Is this legitimate?" to "How do I comply quickly?"

Defensive counter: Establish verification procedures that apply to all requests regardless of claimed authority. "Even the CEO goes through the same verification for wire transfers."

**Urgency and time pressure**: Artificial deadlines prevent the target from thinking critically or seeking verification. "Your account will be locked in 1 hour." "The wire must go out before end of business today."

Defensive counter: Establish a policy that urgency is itself a red flag. Legitimate organizations can wait 15 minutes for verification.

**Fear and consequences**: Threats of negative outcomes (account suspension, legal action, job loss) trigger fight-or-flight response, reducing critical thinking.

Defensive counter: Reassure employees that no legitimate internal request will threaten their job for taking time to verify.

**Curiosity**: "You have a package waiting," "Here are the salary details you requested," "Photos from the company event." Humans are wired to be curious.

Defensive counter: Train on common curiosity lures. Awareness of the technique reduces its effectiveness.

**Helpfulness**: Exploiting the natural desire to be helpful. "I'm new and I forgot my badge." "Can you help me reset my password?" People who work in service roles are particularly vulnerable.

Defensive counter: Verification procedures for all access requests, regardless of how friendly or helpless the requester appears.

## Patterns

### Pattern: Phishing Email Deconstructon
When analyzing a phishing email, examine:
1. **Headers**: SPF/DKIM/DMARC results, Received chain, Message-ID format
2. **Sender**: Display name vs actual address, domain age, typosquatting
3. **Content**: Urgency level, grammar quality, personalization level, brand accuracy
4. **Links**: Hover URL vs displayed text, redirect chains, domain reputation
5. **Attachments**: File type, macro presence, embedded objects
6. **Context**: Timing (end of month for finance, tax season), relevance to recipient

### Pattern: BEC Detection Indicators
- Wire transfer or payment modification request via email
- Request explicitly asks to avoid normal verification channels
- Reply-to differs from From address
- Email arrives when the impersonated person is known to be unavailable
- Language style does not match the impersonated person's typical communication

### Pattern: Multi-Factor Attack Recognition
Attack chains that combine multiple social engineering channels:
Email (pretext) -> Phone call (authority reinforcement) -> SMS (MFA code request)
Each channel reinforces the pretext established by the previous one.

## Anti-Patterns

- **Assuming MFA defeats all phishing**: AiTM phishing proxies capture session tokens after MFA completion. Only FIDO2/WebAuthn provides phishing-resistant authentication
- **Blocking without educating**: Silently blocking phishing emails without showing employees what was blocked misses a training opportunity
- **Treating all phishing as equal**: Mass commodity phishing and targeted BEC require different defenses. Commodity phishing is a volume problem (filtering); BEC is a process problem (verification)
- **Ignoring non-email channels**: Vishing, physical social engineering, and social media attacks bypass email security entirely
- **Static defenses**: Social engineering techniques evolve rapidly. Defenses designed for 2020 phishing do not address 2025 AI-generated deepfake vishing

## References

- Verizon Data Breach Investigations Report (DBIR) -- annual social engineering statistics
- FBI IC3 Annual Reports -- BEC and social engineering financial losses
- MITRE ATT&CK -- Initial Access (T1566 Phishing, T1598 Phishing for Information)
- Hadnagy, Christopher -- "Social Engineering: The Science of Human Hacking"
- Cialdini, Robert -- "Influence: The Psychology of Persuasion"
- KnowBe4 Phishing Benchmark Reports -- industry benchmarking data
- Anti-Phishing Working Group (APWG) quarterly reports -- https://apwg.org/trendsreports/
- Microsoft Digital Defense Report -- social engineering trends

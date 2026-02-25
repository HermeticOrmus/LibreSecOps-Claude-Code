# Social Engineering Taxonomy

> Classification of social engineering attack types, psychological principles exploited, recognition patterns, and organizational defense strategies.

## Knowledge Base

### Definition

Social engineering is the psychological manipulation of people into performing actions or divulging information that benefits the attacker. Unlike technical attacks that exploit software vulnerabilities, social engineering exploits human cognitive biases, trust relationships, and organizational processes.

### Attack Type Classification

**Email-Based Attacks**

| Type | Description | Targeting | Sophistication |
|------|-------------|-----------|---------------|
| Mass phishing | Untargeted emails to many recipients | None - spray and pray | Low |
| Spear phishing | Targeted emails using personal information | Specific individuals | Medium-High |
| Whaling | Phishing targeting executives/senior leadership | C-suite, board members | High |
| BEC (Business Email Compromise) | Impersonating executives to request actions | Finance, accounting, HR | High |
| Vendor impersonation | Impersonating suppliers requesting payment changes | Accounts payable | High |
| Lateral phishing | Phishing from a compromised internal account | Internal targets | Very High |

**Voice-Based Attacks (Vishing)**

| Type | Description | Common Pretext |
|------|-------------|---------------|
| IT support scam | Impersonating IT helpdesk | "We detected a problem with your account" |
| Authority impersonation | Pretending to be law enforcement or government | "This is regarding a tax investigation" |
| Vendor callback | Requesting callback to attacker-controlled number | "Call us back to verify your account" |
| Deepfake voice | AI-generated voice mimicking known individuals | CFO requesting urgent wire transfer |

**SMS/Messaging (Smishing)**

| Type | Description | Common Pretext |
|------|-------------|---------------|
| Package delivery | Fake shipping notifications | "Your package could not be delivered" |
| Banking alerts | Fake fraud alerts from banks | "Suspicious activity on your account" |
| MFA code theft | Requesting MFA codes | "Enter the code we just sent you" |
| Job offer scams | Fake recruiting messages | "We have a position matching your profile" |

**Physical Social Engineering**

| Type | Description | Prevention |
|------|-------------|-----------|
| Tailgating | Following authorized person through secure door | Badge enforcement, mantraps, awareness |
| Impersonation | Pretending to be maintenance, delivery, IT | Visitor badges, escort policies, verification |
| Dumpster diving | Searching trash for sensitive documents | Shredding policy, secure disposal bins |
| Shoulder surfing | Observing screens or keyboards | Privacy screens, awareness, screen lock |
| USB drops | Placing malicious USB drives in parking lots/lobbies | Disable USB autorun, awareness training |

**Digital Social Engineering**

| Type | Description | Prevention |
|------|-------------|-----------|
| Watering hole | Compromising websites frequently visited by targets | Web filtering, monitoring, patching |
| Baiting | Offering something desirable (free software, content) | Download policies, awareness |
| Quid pro quo | Offering help/service in exchange for information | Verification procedures |
| Pretexting | Creating false scenario to extract information | Verification procedures, callback policies |

### Psychological Principles Exploited

**Robert Cialdini's Principles of Influence** (weaponized in social engineering):

1. **Authority** -- People comply with requests from perceived authority figures
   - Attack: Emails from "the CEO" requesting urgent action
   - Defense: Verify identity through separate channel, especially for financial requests

2. **Urgency/Scarcity** -- Time pressure reduces critical thinking
   - Attack: "Your account will be locked in 24 hours unless you verify"
   - Defense: Legitimate organizations rarely impose extreme deadlines. Pause and verify

3. **Social proof** -- People follow what others appear to do
   - Attack: "Everyone in your department has already completed this verification"
   - Defense: Verify independently rather than relying on claimed actions of others

4. **Reciprocity** -- People feel obligated to return favors
   - Attack: Providing "help" with a technical issue, then requesting credentials
   - Defense: Separate the help from the request. Verify identity before sharing information

5. **Likability** -- People comply with requests from people they like
   - Attack: Building rapport before making the request
   - Defense: Process-based verification regardless of personal rapport

6. **Commitment/Consistency** -- People honor prior commitments
   - Attack: Getting small "yes" answers leading to larger compliance
   - Defense: Each request is evaluated independently regardless of prior interaction

### Recognition Patterns

**Email red flags**:
- Sender address does not match claimed identity (inspect the actual address, not just display name)
- Urgency combined with unusual request ("Do this NOW, tell no one")
- Request to bypass normal processes ("Skip the approval workflow this time")
- Links that do not match the claimed destination (hover before clicking)
- Unexpected attachments, especially .exe, .scr, .js, .vbs, .iso, .img
- Emotional manipulation (fear, excitement, curiosity)
- Grammar/spelling errors inconsistent with claimed sender's typical communication

**Phone red flags**:
- Caller requests information that the claimed organization should already have
- Pressure to stay on the line and not verify through other channels
- Request for credentials, MFA codes, or remote access
- Caller becomes aggressive when questioned or asked to verify identity
- Call about an "urgent problem" you were not aware of

**Physical red flags**:
- Unknown person attempting to enter restricted area without escort
- Person claiming to be from a vendor not on the scheduled visit list
- Request to hold a door open ("My badge is not working")
- Unusual questions about security procedures, network infrastructure, or personnel

## Patterns

### Pattern: Verification Callback
When receiving a suspicious request (especially financial), hang up and call the person back using a known-good phone number (from the company directory, not from the email/voicemail). This breaks the attacker's control of the communication channel.

### Pattern: Multi-Channel Verification
For high-risk requests (wire transfers, credential resets, access grants), verify through a different communication channel than the request came through. Email request verified by phone call. Phone request verified by in-person visit or Slack message.

### Pattern: Slow Down on Urgency
The more urgent a request feels, the more important it is to slow down and verify. Legitimate urgent requests can tolerate a 5-minute verification delay. Attacks cannot, because the verification will expose them.

## Anti-Patterns

- **Blaming victims**: Shaming employees who fall for phishing destroys reporting culture. They will hide future incidents instead of reporting them
- **One-time training**: Annual training satisfies compliance but does not build awareness. Continuous, frequent micro-training is required
- **Testing without teaching**: Running phishing simulations without educational follow-up is testing, not training
- **Security through fear**: Threatening consequences for phishing clicks reduces reporting, not clicking. Focus on reporting behavior
- **Over-reliance on technical controls**: Email filters catch most phishing but not all. Human recognition is the last layer of defense
- **Generic training content**: Industry-specific, role-specific training is dramatically more effective than generic "do not click suspicious links" messaging

## References

- Cialdini, Robert -- "Influence: The Psychology of Persuasion" (psychological foundations)
- Hadnagy, Christopher -- "Social Engineering: The Science of Human Hacking" (practical taxonomy)
- SANS Security Awareness Maturity Model -- https://www.sans.org/security-awareness-training/resources/maturity-model
- NIST SP 800-50: Building an Information Technology Security Awareness and Training Program -- https://csrc.nist.gov/publications/detail/sp/800-50/final
- Anti-Phishing Working Group (APWG) -- https://apwg.org/
- ENISA Threat Landscape -- https://www.enisa.europa.eu/topics/threat-risk-management/threats-and-trends
- Verizon Data Breach Investigations Report (DBIR) -- social engineering statistics
- FBI IC3 Reports -- BEC and social engineering loss statistics

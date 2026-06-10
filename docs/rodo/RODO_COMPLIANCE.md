# SilverTech Agent Adam — RODO/GDPR Compliance Documentation

## Document Information
- **Version**: 1.6.0
- **Date**: June 2026
- **Classification**: Internal — Confidential
- **Owner**: SilverTech Data Protection Officer (DPO)
- **Last Review**: 2026-06-01

## 1. Data Processing Overview

### 1.1 Data Controller
**SilverTech Sp. z o.o.**
- NIP: PL-XXXXXXXXX
- REGON: XXXXXXXXX
- Address: [Company Address]
- DPO Contact: dpo@silvertech.ai
- Data Protection Register: [Registration Number]

### 1.2 Processed Personal Data Categories

| Category | Data Elements | Legal Basis | Retention |
|----------|--------------|-------------|-----------|
| **Identity** | Name, PESEL, phone, address | Art. 6(1)(b) — Contract | Active + 5 years |
| **Health** | Medical conditions, HR, SpO2, sleep | Art. 9(2)(h) — Healthcare | Active + 20 years |
| **Voice/Biometric** | Voice recordings, emotion analysis | Art. 9(2)(a) — Explicit Consent | 30 days rolling |
| **Family** | Emergency contacts, relationship | Art. 6(1)(f) — Legitimate Interest | Active + 5 years |
| **Location** | GPS (during SOS only) | Art. 9(2)(c) — Vital Interests | 90 days |
| **Financial** | Package billing, payment history | Art. 6(1)(b) — Contract | 5 years (tax law) |

### 1.3 Data Processing Purposes
1. **Primary**: AI voice assistant for senior well-being monitoring
2. **Secondary**: Health trend analysis, medication reminders, emergency response
3. **Tertiary**: Service improvement analytics (anonymized), package billing

## 2. Data Subject Rights Implementation

### 2.1 Right to Access (Art. 15)
- **Endpoint**: `GET /api/gdpr/export/{user_id}`
- **Response Format**: JSON + PDF download
- **Response Time**: Within 30 days (target: 72 hours)
- **Authentication**: JWT + 2FA for sensitive health data

### 2.2 Right to Rectification (Art. 16)
- **Endpoint**: `PATCH /api/seniors/{id}` (senior self-service)
- **Endpoint**: `PUT /api/admin/seniors/{id}` (admin override)
- **Audit Trail**: All changes logged in `audit_logs` table

### 2.3 Right to Erasure (Art. 17)
- **Endpoint**: `DELETE /api/gdpr/erase/{user_id}`
- **Process**: Soft-delete (30-day recovery) → Hard delete
- **Exceptions**: Health records (legal obligation), billing (tax law)
- **Cascade**: All associated records marked for deletion

### 2.4 Right to Restriction (Art. 18)
- **Toggle**: `PATCH /api/gdpr/restrict/{user_id}`
- **Effect**: Blocks all non-essential processing
- **Voice AI**: Continues for emergency only

### 2.5 Right to Portability (Art. 20)
- **Format**: JSON (structured), PDF (human-readable)
- **Endpoint**: `POST /api/gdpr/export/{user_id}`
- **Scope**: All data provided by data subject + usage logs

### 2.6 Automated Decision-Making (Art. 22)
- **Semafor system**: Automated health risk scoring
- **Human override**: Available via Admin Panel
- **Transparency**: Explanation available via `GET /api/decisions/explain/{decision_id}`

## 3. Technical & Organizational Measures (Art. 32)

### 3.1 Encryption
| Data State | Method | Key Management |
|-----------|--------|---------------|
| **At Rest** | AES-256-GCM | AWS KMS / HashiCorp Vault |
| **In Transit** | TLS 1.3 | Let's Encrypt (auto-renew) |
| **Database** | pgcrypto column-level | Per-tenant encryption keys |
| **Backups** | AES-256 + GPG | Offline key storage |

### 3.2 Access Control
- **RBAC**: 4 roles (Senior, Family, Admin, SuperAdmin)
- **MFA**: Required for Admin/SuperAdmin roles
- **Session**: 24h JWT + refresh token rotation
- **IP Whitelist**: Optional for admin panel
- **Audit**: All access logged (who, what, when, IP)

### 3.3 Pseudonymization
- Voice recordings: Identified by UUID only
- Analytics: Aggregated minimum 10 users
- Test data: Synthetic only (never production data)

### 3.4 Incident Response
- **Detection**: Automated anomaly monitoring (Sentry + Healthchecks.io)
- **Notification**: DPO within 1 hour, Supervisory Authority within 72 hours
- **Data Subjects**: Notified within 72 hours if high risk
- **Post-Mortem**: RCA within 5 business days

## 4. Data Processing Agreements (Art. 28)

### 4.1 Sub-Processors

| Processor | Service | Data Location | DPA Signed |
|-----------|---------|---------------|------------|
| **Hetzner** | VPS Hosting | EU (Germany) | ✓ |
| **Supabase** | Database | EU (Frankfurt) | ✓ |
| **Deepgram** | STT (Nova-3) | US/EU | ✓ (SCCs) |
| **Google (Gemini)** | LLM | US/EU | ✓ (SCCs) |
| **OpenAI** | TTS | US/EU | ✓ (SCCs) |
| **Twilio** | Telephony | EU (Ireland) | ✓ |
| **Sentry** | Error Tracking | EU (Frankfurt) | ✓ |

### 4.2 International Transfers
For US-based processors (Deepgram, OpenAI, Google):
- Standard Contractual Clauses (SCCs) signed
- Transfer Impact Assessment (TIA) completed
- Additional safeguards: Encryption in transit, no persistent storage of voice data

## 5. Data Protection Impact Assessment (Art. 35)

### 5.1 Identified Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Voice recording breach | Low | High | 30-day retention, encryption, access control |
| Health data leak | Low | Critical | Column-level encryption, HIPAA-compliant storage |
| Unauthorized SOS trigger | Medium | Medium | 3-step confirmation, audit trail |
| AI bias in mood detection | Medium | Medium | Regular bias audits, human override |
| Wearable data interception | Low | Medium | BLE encryption, Health Connect API |

### 5.2 Residual Risk Assessment
After mitigations: **LOW** (acceptable)
DPIA Review: Annual + after any major change

## 6. Consent Management (Art. 7)

### 6.1 Consent Collection
- **Onboarding**: Clear, separate checkboxes per purpose
- **Language**: Polish (primary), English (secondary)
- **Withdrawal**: 1-click in settings or voice command "Adam, cofnij zgodę"
- **Granularity**: Per-purpose consent (not all-or-nothing)
- **Children**: Service not intended for persons under 60

### 6.2 Consent Record
- **Table**: `consent_records`
- **Fields**: user_id, purpose, granted_at, withdrawn_at, ip_address, consent_version
- **Retention**: Duration of processing + 5 years

## 7. Data Retention & Deletion Schedule

| Data Type | Active Retention | Archive | Deletion |
|-----------|-----------------|---------|----------|
| Voice recordings | 30 days | N/A | Auto-delete day 31 |
| Transcripts (text) | Active period | 5 years (anonymized) | Delete on request |
| Health metrics | Active period | 20 years (medical) | Per legal requirement |
| Account data | Active period | 5 years | Delete on request |
| Billing data | Active period | 5 years (tax) | Per legal requirement |
| Audit logs | 3 years | 5 years | Auto-delete year 6 |

## 8. Breach Notification Procedure

### 8.1 Internal Escalation
1. **Detection** → Security Team (15 min)
2. **Triage** → DPO + CTO (1 hour)
3. **Containment** → Engineering Team (2 hours)
4. **Assessment** → DPO (24 hours for SA notification decision)

### 8.2 External Notification
- **Supervisory Authority (UODO)**: Within 72 hours
- **Affected Seniors**: Within 72 hours (SMS + app notification + phone call)
- **Family Contacts**: Within 72 hours
- **Media/PR**: Per communication plan (if applicable)

## 9. Documentation & Evidence

### 9.1 Records of Processing Activities (Art. 30)
- Location: `/docs/rodo/ROPA_2026.xlsx`
- Updated: Quarterly
- Available: On request to UODO

### 9.2 Compliance Evidence
- Penetration test reports: `/docs/security/pentests/`
- Vulnerability scans: Automated weekly (OWASP ZAP)
- Policy acknowledgments: Tracked per employee
- Training records: Annual GDPR refresher

## 10. Contact & Resources

- **DPO**: dpo@silvertech.ai | +48 XXX XXX XXX
- **UODO (Polish DPA)**: kancelaria@uodo.gov.pl
- **Data Breach Hotline**: +48 XX XXX XX XX (24/7)
- **Internal Wiki**: https://wiki.silvertech.ai/rodo

---

*This document is reviewed and signed annually by the DPO and CEO.*
*Next review: June 2027*

**Signatures:**
- Data Protection Officer: _______________ Date: ___________
- Chief Executive Officer: _______________ Date: ___________

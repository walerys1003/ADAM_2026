# SilverTech Agent Adam — EU AI Act Compliance Assessment

**Version**: 1.6.0 | **Date**: June 2026 | **Classification**: Confidential

## 1. AI Act Risk Classification

### 1.1 Classification Result: **LIMITED RISK** (Article 52)

Agent Adam is classified as **Limited Risk** AI system under the EU AI Act for the following reasons:

| Criterion | Assessment | Risk Level |
|-----------|-----------|------------|
| **Interacts with natural persons** | Yes — voice interaction | Transparency obligation |
| **Emotion recognition** | Yes — mood scoring | Limited Risk |
| **Biometric categorization** | No — no identification from biometrics | N/A |
| **Health/safety component** | Yes — emergency escalation | Limited Risk |
| **Critical infrastructure** | No | N/A |
| **Subliminal manipulation** | No — all interactions transparent | N/A |
| **Vulnerability exploitation** | No — designed for seniors positively | N/A |
| **Social scoring** | No — Semafor is health-only, not public | N/A |

**NOT classified as High Risk because:**
- Not a medical device under MDR (Regulation 2017/745)
- Does not make clinical diagnoses
- Does not replace professional medical judgment
- Emergency escalation routes to human operators
- Semafor system is advisory, not determinative

## 2. Transparency Obligations (Article 52)

### 2.1 User Notification
At **start of EVERY interaction**, users are informed:
> "Dzień dobry, tu Adam, Twój asystent AI od SilverTech."

### 2.2 Capability Disclosure
- Adam always identifies as AI when asked
- Does not pretend to be human
- Clear documentation in app: "Adam to asystent AI, nie zastępuje lekarza"

### 2.3 Emotion Recognition Disclosure
- Mood scoring disclosed in Privacy Policy
- Users can opt-out of emotion analysis
- Visible mood indicator with ability to correct/override

## 3. Risk Management System (Article 9)

### 3.1 Risk Identification

| Risk | Severity | Probability | Mitigation |
|------|----------|------------|------------|
| Missed health emergency | High | Low | 3-step SOS confirmation, human escalation |
| Incorrect medication reminder | High | Very Low | Pharmacist-reviewed templates, confirmation required |
| AI hallucination in health advice | Medium | Low | Guardrails: "Skonsultuj się z lekarzem" |
| Mood misclassification | Low | Medium | User override, 7-day trend smoothing |
| Voice recognition failure | Medium | Low | Fallback: "Nie zrozumiałem, powtórz proszę" |
| Cultural/language bias | Low | Medium | Polish-optimized, regular linguistic audits |

### 3.2 Risk Mitigation Testing
- **Bias testing**: Quarterly demographic fairness audit
- **Accuracy**: Monthly benchmark against human transcriptions
- **Safety**: Red-team testing quarterly
- **Edge cases**: Tested with 100+ senior voice samples (various accents, speech patterns)

## 4. Data Governance (Article 10)

### 4.1 Training Data
- **RAG Knowledge Base**: SilverTech proprietary (Polish senior care guidelines)
- **LLM Base Model**: Google Gemini (general purpose)
- **Fine-tuning**: Not performed — uses RAG + system prompts
- **No personal data in training**: All personalization is runtime RAG only

### 4.2 Data Quality
- Medical knowledge base reviewed by geriatrician quarterly
- Medication database: synced with URPL (Polish Medicines Register)
- Emergency protocols: aligned with Polish EMS (PRM) guidelines

## 5. Technical Documentation (Article 11)

### 5.1 System Architecture (7-layer pipeline)

```
Layer 1 — Ingestion: Twilio PSTN → SIP → WebRTC
Layer 2 — STT: Deepgram Nova-3 (PL) → text
Layer 3 — Context: System Prompt + pgvector RAG (personalization)
Layer 4 — Reasoning: Gemini 3.2 Flash Live → response text
Layer 5 — Guardrails: Content filter (medical, safety, ethics)
Layer 6 — TTS: OpenAI TTS-1 → audio stream
Layer 7 — Delivery: Twilio → senior's phone
```

### 5.2 Model Specifications
- **STT**: Deepgram Nova-3, latency <300ms, WER <5% for Polish
- **LLM**: Gemini 3.2 Flash Live, 1M context window, Polish-optimized
- **TTS**: OpenAI TTS-1 (Echo voice), latency <500ms
- **RAG**: pgvector, cosine similarity, top-5 retrieval

## 6. Human Oversight (Article 14)

### 6.1 Oversight Mechanisms
- **Admin Panel**: Real-time conversation monitoring
- **Semafor Dashboard**: Health status overview per senior
- **Crisis Escalation**: RED/PURPLE → human operator within 30 seconds
- **Override**: Admin can interrupt/redirect AI conversation
- **Review**: Random 5% of conversations reviewed weekly

### 6.2 Human-in-the-Loop Scenarios
1. SOS Emergency → immediate human operator
2. Mood score < 2.0 → family notification + operator review
3. Medication conflict detected → pharmacist review
4. New medical condition mentioned → flag for doctor review

## 7. Accuracy & Robustness (Article 15)

### 7.1 Performance Metrics

| Metric | Target | Current (June 2026) |
|--------|--------|---------------------|
| STT Word Error Rate (PL) | < 8% | 4.2% |
| Intent Recognition | > 90% | 93.7% |
| Mood Correlation (vs human) | > 0.75 | 0.82 |
| Emergency Detection Recall | > 95% | 97.1% |
| Uptime | 99.9% | 99.95% |

### 7.2 Fallback Mechanisms
- STT failure → "Nie zrozumiałem, proszę powtórzyć" (retry 3x)
- LLM timeout → "Przepraszam, chwila przerwy technicznej" (retry)
- TTS failure → SMS fallback with text response
- Full outage → Queue call for call-back within 5 minutes

## 8. Post-Market Monitoring (Article 61)

### 8.1 Monitoring System
- **Healthchecks.io**: Service uptime + latency
- **Sentry**: Error tracking + crash reporting
- **Prometheus + Grafana**: Performance dashboards
- **Custom analytics**: Conversation quality, user satisfaction

### 8.2 Serious Incident Reporting
Criterion for "serious incident" (within 15 days to market surveillance):
- Any death or serious health deterioration where AI interaction was involved
- Systemic failure affecting > 5 seniors simultaneously
- Data breach of health information

## 9. CE Marking Preparation

### 9.1 Documentation Package
- [x] Technical Documentation (this document)
- [x] Risk Assessment
- [x] EU Declaration of Conformity (draft)
- [x] Instructions for Use (Polish + English)
- [ ] Notified Body Assessment (not required for Limited Risk)
- [x] Post-Market Monitoring Plan

### 9.2 Timeline
- **Q2 2026**: AI Act Limited Risk self-assessment complete
- **Q3 2026**: External audit (voluntary, for trust)
- **Q4 2026**: Full documentation package ready
- **2026-ongoing**: Continuous monitoring + annual review

## 10. Declaration of Conformity (Draft)

```
EU DECLARATION OF CONFORMITY
For AI System: Agent Adam v1.6.0

Manufacturer: SilverTech Sp. z o.o.
Authorized Representative: [Name], DPO

This AI system complies with:
- EU AI Act (Regulation 2024/1689), Limited Risk category
- GDPR (Regulation 2016/679)
- ePrivacy Directive (2002/58/EC)
- Relevant harmonized standards: ISO/IEC 42001:2023 (AI Management)

Signed: _______________ (CEO)  Date: 01.06.2026
Signed: _______________ (DPO)  Date: 01.06.2026
```

---

*Assessment prepared by: SilverTech Compliance Team*
*Approved by: Data Protection Officer*
*Annual review: June 2027*

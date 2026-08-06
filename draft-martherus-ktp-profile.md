---
title: "Kinetic Trust Protocol Profile for Agentic Governance Interchange"
abbrev: "KTP Profile"
docname: draft-martherus-ktp-profile-00
category: exp
ipr: trust200902
area: Security
workgroup: Independent Submission
keyword: [trust, delegation, attenuation, autonomous agents, KTP]
stand_alone: yes
pi: [toc, sortrefs, symrefs]
author:
  -
    ins: R. Martherus
    name: Robin Martherus
    organization: Independent
    email: robin@martherus.com
normative:
  RFC2119:
  RFC8174:
  I-D.martherus-authority-attenuation:
    title: "Authority Attenuation Predicates for Delegation Chains"
    author:
      - ins: R. Martherus
    date: 2026
  I-D.martherus-trust-observation:
    title: "Portable Trust Observations for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
  KTP-IDENTITY:
    title: "KTP-Identity: Vector Identity and Trajectory Chains"
    author:
      - ins: C. Perkins
        org: New Mexico Cyber Intelligence & Threat Response Alliance
    target: https://nmcitra.github.io/ktp-rfc/rfcs/ktp-identity/
    date: 2026
  KTP-CORE:
    title: "KTP-Core: Trust Score, Context Tensor, Trust Proof"
    author:
      - ins: C. Perkins
        org: New Mexico Cyber Intelligence & Threat Response Alliance
    target: https://nmcitra.github.io/ktp-rfc/rfcs/ktp-core/
    date: 2026
  KTP-ENFORCE:
    title: "KTP-Enforce"
    author:
      - ins: C. Perkins
        org: New Mexico Cyber Intelligence & Threat Response Alliance
    target: https://nmcitra.github.io/ktp-rfc/rfcs/ktp-enforce/
    date: 2026
---

# Kinetic Trust Protocol Profile for Agentic Governance Interchange

**Status:** Pre-submission working copy. Not filed with the IETF Datatracker.

⚠️ **Do not file without co-author discussion.** This document profiles the Kinetic Trust Protocol,
authored by Chris Perkins (New Mexico Cyber Intelligence & Threat Response Alliance) and published under
Apache License 2.0. See Section 8.

---

## Abstract

This document profiles the Kinetic Trust Protocol (KTP) as a trust and delegation-chain substrate for two
companion specifications: authority attenuation predicates and portable trust observations.

It exists so that those specifications need not depend on KTP. Each stands alone with no KTP reference of
any kind. A deployment that has chosen KTP uses this profile to bind them together; a deployment that has
not is unaffected.

---

## 1. Introduction

KTP defines a physics-derived model in which an agent's effective trust is computed from its accumulated
standing and current environmental conditions, and in which agent identity is a trajectory rather than a
credential. Two of its documents are directly relevant here: KTP-Core {{KTP-CORE}} defines the trust
score and the signed Trust Proof, and KTP-Identity {{KTP-IDENTITY}} defines append-only trajectory chains
and sponsorship bonds.

{{I-D.martherus-authority-attenuation}} defines predicates describing how *permission* narrows across a
delegation hop, and requires an append-only chain to carry them without specifying which. KTP-Identity
supplies one.

{{I-D.martherus-trust-observation}} defines signed observations by named observers and deliberately
defines no trust scale. KTP supplies one, scoped to an issuing oracle.

### 1.1 Why this is a separate document

The two companion specifications are intended for a standards process. KTP is published by a single
organization outside any recognized standards body. Binding the base specifications to it would make
their progress contingent on KTP's, and would require every implementer to evaluate KTP whether or not
they use it.

Isolating the dependency here means the reference to KTP appears in exactly one document, which can be
evaluated on its own terms.

### 1.2 Two quantities, two evaluations

A delegation chain carries two distinct quantities that are easily conflated:

- **Authority** — what the delegate is permitted to do. A static grant, fixed at the hop, narrowable only
  downward. Governed by {{I-D.martherus-authority-attenuation}}.
- **Trust** — how much standing the agent has right now. A dynamic quantity, recomputed from conditions.
  Governed by {{KTP-CORE}} and {{KTP-ENFORCE}}.

Under this profile both are evaluated and **neither substitutes for the other.** An agent may hold
sufficient trust for an action its attenuated authority forbids, and may hold authority for an action its
current trust does not support. An implementation **MUST NOT** derive authority from a trust quantity, or
trust from an attenuation predicate.

---

## 2. Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they appear in all capitals.

Terms from {{KTP-CORE}} and {{KTP-IDENTITY}} — Trust Proof, trajectory chain, transaction record,
Sponsorship Bond, `E_base`, `E_trust` — are used as defined there.

---

## 3. Carrying Attenuation in a Trajectory Chain

{{I-D.martherus-authority-attenuation}} Section 4.1 permits its predicates to be carried in an existing
chain, provided the binding names the carrying field and preserves ordering and hash-linking.

Under this profile:

- The attenuation set is carried in a transaction record's action detail object, under an `attenuation`
  member whose value is an array of predicates as defined in
  {{I-D.martherus-authority-attenuation}} Section 5.
- The trajectory chain's `previous_hash` satisfies the hash-linking requirement.
- The chain's append-only property satisfies the ordering requirement.

### 3.1 Delegation depth MUST NOT be derived from `sequence`

**This is the most important requirement in this document.**

{{I-D.martherus-authority-attenuation}} Section 6 requires that delegation depth increment by exactly one
per hop. A trajectory chain's `sequence` counts *every* transaction record — actions, state transitions,
and attestations — not only delegation events. Delegation hops are a subset of transaction records, and
in any realistic chain a strict subset.

Therefore `sequence` **MUST NOT** be used as, or mapped to, delegation depth. A profile that equated them
would produce depth values that skip, causing conforming verifiers to reject valid chains and — where a
`depth` attenuation predicate bounds onward delegation — to compute remaining depth wrongly.

Instead, a transaction record carrying an `attenuation` member **MUST** also carry an explicit `depth`
member within the same action detail object, set to the number of preceding delegation hops in the chain.
A verifier **MUST** use that member and **MUST NOT** infer depth from `sequence`.

A verifier evaluating a chain under this profile **MUST** consider only transaction records carrying an
`attenuation` member when evaluating the requirements of
{{I-D.martherus-authority-attenuation}} Section 6. Records without one are not delegation hops and do not
participate in monotonicity, depth, or composed-authority evaluation.

### 3.2 Signatures

KTP-Identity requires that each transaction record carry an agent signature and an Oracle attestation.
{{I-D.martherus-authority-attenuation}} Section 4.3 recommends a delegate signature attesting acceptance
of the stated attenuation.

**These are different signatures serving different purposes and neither satisfies the other.** The Oracle
attestation validates the record's admission to the chain. The delegate signature attests that the
delegate accepted the attenuation.

A deployment requiring delegate accountability **MUST** carry a delegate signature over the attenuation
set in addition to the signatures KTP-Identity requires. An implementation **MUST NOT** treat the Oracle
attestation as satisfying that requirement.

---

## 4. Trust Proofs as Trust Observations

A KTP Trust Proof {{KTP-CORE}} is a signed, short-lived assertion by a named Trust Oracle about an
agent's standing under stated conditions. That is structurally an observation in the sense of
{{I-D.martherus-trust-observation}}: a named observer, a bounded window, a signed statement.

A Trust Proof **MAY** be consumed as a trust observation under the following mapping:

| Observation member | Trust Proof source |
|---|---|
| `observer` | The `iss` claim (the issuing oracle) |
| `subject` | The `sub` claim |
| `type` | `attestation_result` |
| `window_start` / `window_end` | `iat` and `exp` |
| `method` | `direct_enforcement` where the oracle observed directly; otherwise `model_inference` |
| `expires` | `exp` |

### 4.1 `e_trust` is not a portable trust score

{{I-D.martherus-trust-observation}} Section 3 prohibits an observation from carrying a general-purpose
trust score, on the grounds that no symmetric reputation function is sybilproof.

A Trust Proof carries `e_trust` on a 0–100 scale. **An implementation consuming Trust Proofs as
observations MUST NOT treat `e_trust` as a portable trust score.**

The value is meaningful only relative to the issuing oracle, its Context Tensor, and the environmental
conditions at the stated instant. Two Trust Proofs from different oracles are not comparable, and an
implementation **MUST NOT** aggregate `e_trust` values across oracles into a single figure, or re-emit
any such aggregate as an observation.

The prohibition in {{I-D.martherus-trust-observation}} Section 3 is not relaxed by this profile.

Note that KTP's model is not straightforwardly subject to the sybilproofness result in the first place:
`E_trust` is the product of accumulated standing and an environmental risk factor derived from sensor
input, not a function aggregating reports from other identities. Whether the accumulated-standing
component is entirely self-earned, and therefore whether the result applies at all, **is an open item**
(Section 9).

### 4.2 Newcomer distrust

{{I-D.martherus-trust-observation}} Section 6.2 requires that a subject with no observations be
distinguishable from one with favorable observations.

KTP satisfies this structurally: an agent begins with low `E_base` and raises it by surviving, and
{{KTP-ENFORCE}} places an agent below its lowest tier threshold in a minimal-capability state. A
deployment under this profile **MUST NOT** configure a floor that admits an unproven agent to a tier its
accumulated standing does not support.

---

## 5. Sponsorship

{{I-D.martherus-trust-observation}} defines a `sponsor_conduct` observation type keyed by a sponsor
identifier, and deliberately does not define how a sponsorship relation is established.

Under this profile, the sponsorship relation is a KTP Sponsorship Bond {{KTP-IDENTITY}}, and the sponsor
identifier used in a `sponsor_conduct` observation **MUST** be the bond's `sponsor_id`.

This profile does not restate the bond's semantics — stake, transfer ratio, or the relation by which a
sponsor's contribution decays as the sponsored agent accumulates its own standing. Those are governed
entirely by {{KTP-IDENTITY}} and an implementation **MUST NOT** derive them from anything in the
companion specifications.

---

## 6. Enforcement Ordering

{{KTP-ENFORCE}} defines an evaluation sequence: Trust Proof validation, sovereignty veto, tier
eligibility, the A ≤ E constraint, then custom policy.

Authority attenuation is a *custom policy* input in that sequence, not a replacement for any step. A
deployment under this profile **MUST** evaluate composed authority
({{I-D.martherus-authority-attenuation}} Section 6) and **MUST NOT** treat a passing KTP evaluation as
authorizing an action outside the composed authority.

The converse also holds: composed authority permitting an action does not satisfy KTP's constraints, and
an implementation **MUST NOT** bypass them on that basis.

---

## 7. Security Considerations

**Two evaluations, two failure modes.** A deployment that implements this profile but evaluates only one
quantity has a gap it may not perceive, because each evaluation returns a confident answer to a different
question. Implementations **SHOULD** log which evaluations ran, so that a decision reached with only one
is distinguishable after the fact.

**Depth confusion is exploitable.** Section 3.1 exists because an implementation deriving depth from
`sequence` would compute remaining delegation depth incorrectly. Where a `depth` predicate bounds onward
delegation, that error is a privilege escalation: an agent interleaving non-delegation transactions
inflates `sequence` and, under a naive mapping, appears to have exhausted a depth budget it has not — or,
depending on the direction of the error, retains budget it should have spent.

**Oracle compromise.** Under this profile a compromised Trust Oracle can issue favorable Trust Proofs and
attest arbitrary chain records. It cannot forge a delegate signature over an attenuation set, which is
the principal reason Section 3.2 keeps the signatures distinct. Deployments **SHOULD** treat oracle
compromise as within their threat model and **SHOULD NOT** rely on a single oracle for both trust
issuance and chain attestation.

**Reference stability.** This profile depends on a specification outside any standards body's change
control. A KTP revision may alter the structures profiled here without notice. Implementations
**SHOULD** pin the KTP revision they were built against and **MUST NOT** assume this profile remains
accurate across KTP versions. See Section 9.

---

## 8. Attribution and IPR

The Kinetic Trust Protocol is the work of **Chris Perkins**, New Mexico Cyber Intelligence & Threat
Response Alliance, published under the Apache License, Version 2.0 at
`https://nmcitra.github.io/ktp-rfc/`.

This document profiles that work. It claims no authorship of it, and nothing here should be read as
specifying, extending, or revising KTP itself.

**Before submission:** the author of this document intends to contact Chris Perkins. Preferred outcomes,
in order: co-authorship of this profile; contribution of the profile to the KTP document set directly; or
publication as an independent profile with KTP as a normative reference and explicit acknowledgment.
Filing without that contact is not appropriate for a document whose subject is another author's
specification.

---

## 9. Open Items

1. **Verify every structural claim against the KTP full text.** This profile was written against the
   rendered documentation pages, not the authoritative specifications in the repository's `rfcs-txt/`
   directory. Field names, the `sequence` semantics asserted in Section 3.1, the Trust Proof claim set in
   Section 4, and the Sponsorship Bond members in Section 5 all require confirmation against the source.
2. **Confirm whether `E_base`'s accumulated-standing component is entirely self-earned.** Section 4.1's
   argument that the sybilproofness result does not apply depends on it. If any component aggregates
   reports from other identities, the argument fails and the section needs rewriting.
3. **Determine the normative reference status KTP can actually carry.** As a specification published
   outside a recognized standards body, it may constitute a downward reference requiring justification.
   That question belongs to this document alone — which is why this document exists.
4. **Confirm KTP's versioning and change-control practice** before asserting the pinning guidance in
   Section 7.
5. Decide whether tier thresholds should be restated here. {{KTP-ENFORCE}} publishes them and
   {{KTP-CORE}} does not; restating them would duplicate a value that may change.

---

## 10. IANA Considerations

This document requests no IANA actions. It profiles existing registries and defines no new values.

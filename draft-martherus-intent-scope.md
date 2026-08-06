---
title: "Intent Scope Declarations for Autonomous Agents"
abbrev: "Intent Scope Declarations"
docname: draft-martherus-intent-scope-00
category: exp
ipr: trust200902
area: Security
workgroup: Independent Submission
keyword: [authorization, purpose, intent, autonomous agents]
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
  RFC8259:
  RFC8949:
  RFC9052:
  RFC7515:
  I-D.martherus-authority-attenuation:
    title: "Authority Attenuation Predicates for Delegation Chains"
    author:
      - ins: R. Martherus
    date: 2026
informative:
  RFC6838:
  W3C.trace-context:
    title: "Trace Context"
    target: https://www.w3.org/TR/trace-context/
    author:
      - org: World Wide Web Consortium
    date: 2021-11
  RFC9396:
  RFC8693:
  I-D.martherus-normative-constraint:
    title: "Normative Constraint Exchange for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
  I-D.martherus-trust-observation:
    title: "Portable Trust Observations for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
  I-D.martherus-claim-resolution:
    title: "Multi-Issuer Claim Resolution for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
---

# Intent Scope Declarations for Autonomous Agents

**Status:** Pre-submission working copy. Not filed with the IETF Datatracker.

---

## Abstract

An access token states what an agent may do. It does not state what the agent is doing it *for*. Where a
single credential authorizes a broad class of operations, actions that are individually permitted may
collectively serve a purpose no one authorized.

This document defines a signed, amendable declaration of an agent's operating scope — the resources,
action classes, time bounds, data classifications, and delegation rights within which it has declared it
will act — together with the rules for amending it and the record required to compare declaration against
behavior.

This document does **not** define intent verification. Verification of an agent's purpose from its
observable actions is not achievable against an adversary, and Section 7 states why. What is specified
here is falsification: a declaration that can be shown to have been violated, and a violation that is
attributable.

---

## 1. Introduction

OAuth 2.0 Rich Authorization Requests {{RFC9396}} allow an authorization request to carry structured
detail about the access sought, and Token Exchange {{RFC8693}} allows a token to be exchanged with
narrowed authority. Both improve the precision of *what is authorized*. Neither carries a statement of
*to what end*, nor any mechanism for comparing subsequent behavior against such a statement.

An agent authorized to read a customer relationship management system in order to produce a quarterly
sales report holds a credential that is equally valid for reading that system to assemble a departure
package. Both are reads. Both are in scope. The difference is purpose, and purpose is currently a comment
in a runbook.

### 1.1 Falsification, not verification

The naive form of this specification would declare a purpose, observe the agent, and verify that the
behavior matched. That is not available.

The goal-recognition literature has established the result directly. Deciding plan existence under
controlled observability is EXPSPACE-complete. More decisively, there exist constructions by which an
agent can guarantee a chosen degree of goal ambiguity *even when its planning algorithm is fully known to
the observer* — a Kerckhoffs-style guarantee, robust to replay. A published standard is full disclosure
by definition, so this is the adversary model this document must assume rather than one it can design
around.

The literature also refutes the obvious fallback. A deceptive action sequence need not be inefficient: it
has been shown that a fully deceptive path can also be a fully rational, minimum-cost one. A detector
keying on resource anomaly, latency, or plan cost has a published and implemented bypass.

Accordingly this document specifies:

- a **declaration** that is signed, addressable, and amendable only by signed amendment;
- a **comparison record** that makes divergence between declaration and behavior observable and
  attributable;
- an **observation distinguishability requirement** on the enforcement point (Section 6).

It does not specify a recognizer, and Section 7 explains why standardizing one would be an error.

### 1.2 Relationship to prior work

South et al., "Authenticated Delegation and Authorized AI Agents," proposes OAuth 2.0 and OpenID Connect
extensions for delegating scoped authority to agents, and is the nearest prior art to this document. It
argues the shape convincingly. It does not register parameters, define claim names, specify a token
format, or provide security considerations. This document is intended to be compatible with that
direction and to supply the artifact.

The Platform for Privacy Preferences standardized machine-readable purpose once already. Measured
deployments found roughly one in three compact policies invalid, with identical invalid tokens circulated
as a workaround recipe. P3P declarations opened a gate and were never compared against behavior.

**That failure is the design requirement.** A declaration paired with no observation channel and no cost
for divergence will be falsified at scale. Section 5 makes the comparison record mandatory rather than
optional for this reason.

---

## 2. Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they appear in all capitals.

**Declaration:** A signed statement of the scope within which an agent asserts it will operate.

**Declarant:** The party that signs the declaration. Not necessarily the agent (Section 3.1).

**Divergence:** An observed action outside the declared scope.

**Comparison Record:** The record of an evaluation of an action against a declaration.

### 2.1 Artifact state vocabulary

Used consistently across this document set. Each document defines its own *consequences*; the terms mean
the same thing everywhere.

| Term | Meaning |
|---|---|
| `absent` | No artifact exists or none was found |
| `unavailable` | An artifact exists but could not be retrieved, or verification could not be *attempted* — key unavailable, algorithm unsupported, endpoint unreachable |
| `untrusted` | Retrieved and well-formed, but its issuer is outside the relying party's accepted set |
| `invalid` | Verification was attempted and **failed** — signature does not verify, or content is malformed |
| `expired` | Retrieved and valid, but past its stated validity |

`unavailable` **MUST NOT** be reported or treated as `absent`. Note that this vocabulary describes the
state of an *artifact*; the `undeterminable` comparison result of Section 5 describes the state of an
*evaluation* and is distinct.

---

## 3. Declaration Object

A JSON {{RFC8259}} or CBOR {{RFC8949}} object.

| Member | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Stable identifier |
| `declarant` | string | yes | Accountable signing party |
| `subject` | string | yes | The agent the declaration governs |
| `purpose` | string | yes | Human-readable statement of end |
| `resource` | array | yes | Resource classes in scope |
| `action_class` | array | yes | Permitted action classes |
| `data_classification` | array | no | Data classes the agent may handle |
| `not_before` / `not_after` | string | yes | RFC 3339 validity bounds |
| `delegation` | object | no | Delegation rights (Section 3.2) |
| `amendment` | object | yes | Amendment rules (Section 4) |
| `prior` | string | no | Identifier of the declaration this amends |

Declarations **MUST** be signed with JOSE {{RFC7515}} or COSE {{RFC9052}}, **MUST** carry an explicit
algorithm identifier, and **MUST** support algorithm migration. Declarations govern actions whose records
are retained for years; see {{I-D.martherus-normative-constraint}} Section 7.1.

`purpose` is human-readable and is **NOT** machine-evaluated. It exists for audit and for the human who
must later decide whether a divergence mattered. Implementations **MUST NOT** attempt to derive
enforcement behavior from it.

### 3.1 The declarant is not the agent

A declaration signed by the agent it governs is a self-report and carries the weight of one. Deployments
**SHOULD** require that declarations be signed by the party that deployed or delegated to the agent.

Where an agent signs its own declaration, relying parties **MUST** treat the declaration as
self-asserted, and **MUST NOT** use it as evidence for any property the agent has an incentive to
misstate.

### 3.2 Delegation rights

The `delegation` object states whether the subject may delegate and under what constraints.

| Member | Type | Description |
|---|---|---|
| `permitted` | boolean | Whether delegation is allowed at all |
| `strict` | boolean | Whether each hop must strictly narrow at least one predicate |
| `bounds` | object | Initial attenuation set applying at the first hop |

**This object declares delegation policy; it does not define attenuation semantics.** `bounds` members
are drawn from the attenuation predicate registry of {{I-D.martherus-authority-attenuation}}, and the
meaning of each predicate, the monotonicity rule, and the verification procedure are specified there.
This document does not define a parallel vocabulary.

`strict` **MUST** default to true. A delegation chain in which no predicate narrows is a credential copy
with extra steps. Its enforcement is {{I-D.martherus-authority-attenuation}} Section 5.2.

A `fanout` bound may be stated in `bounds`, and unbounded delegation at full strength — an agent minting
many children each holding the parent's authority — is the pattern it exists to make refusable. Note the
limitation recorded in {{I-D.martherus-authority-attenuation}} Section 5.3: `fanout` is not verifiable
from a single chain and requires an enumeration mechanism. A declaration stating a `fanout` bound in a
deployment providing no such mechanism is advisory.

---

## 4. Amendment

Scope changes. An agent given a broader task mid-operation needs a broader declaration, and a
specification that forces a new declaration for every change will be routed around.

The `amendment` object states the rules:

| Member | Type | Description |
|---|---|---|
| `permitted` | boolean | Whether amendment is allowed |
| `authority` | array | Identifiers permitted to sign amendments |
| `may_broaden` | boolean | Whether an amendment may widen scope |
| `notice` | string | `none`, `notify`, or `approve` |

An amendment **MUST** be a new declaration carrying `prior` set to the identifier of the declaration it
amends, signed by an identifier in `authority`.

A declaration **MUST NOT** be modified in place. The amendment chain is the record of what was declared
when, and an implementation that mutates a declaration destroys the ability to determine what was in
force at the time of an action.

Where `may_broaden` is false, an amendment that widens `resource`, `action_class`, or
`data_classification` **MUST** be rejected.

A relying party evaluating an action **MUST** evaluate against the declaration in force at the time of
the action, not the current head of the amendment chain. Retroactive broadening **MUST NOT** convert a
past divergence into compliance.

---

## 5. Comparison Record

An enforcement point evaluating an action against a declaration **MUST** emit a comparison record.

| Member | Type | Required | Description |
|---|---|---|---|
| `action_ref` | string | yes | W3C Trace Context `trace-id` of the action (Section 5.1) |
| `declaration` | string | yes | Declaration identifier and version |
| `result` | string | yes | `in_scope`, `divergent`, or `undeterminable` |
| `dimension` | array | no | Which members were exceeded, when divergent |
| `observed_at` | string | yes | RFC 3339 |
| `vantage` | string | yes | The enforcement point class |

`undeterminable` **MUST** be used where the enforcement point cannot resolve whether the action fell
within scope. It **MUST NOT** be reported as `in_scope`. An enforcement point that reports what it could
not determine as compliant reproduces P3P's failure exactly.

A comparison record **MUST** be signed by the enforcement point that produced it, using JOSE
{{RFC7515}} or COSE {{RFC9052}}, with an explicit algorithm identifier.

The signature is what makes divergence attributable rather than merely logged. An unsigned comparison
record asserts that some system observed a divergence; a signed one asserts which system did, and can be
presented to a party that does not operate that system. Since attribution is the only security property
this document claims (Section 7), a record that cannot carry it defeats the specification's purpose.

Comparison records are the input to the `intent_compliance` trust observation type; see
{{I-D.martherus-trust-observation}} Section 5.1.

---

### 5.1 Action reference

Records produced by this specification correlate with records produced by companion specifications for
the same action. Correlation uses the `trace-id` of W3C Trace Context {{W3C.trace-context}}.

A record **MUST** carry an `action_ref` member whose value is the 16-byte `trace-id`, hex-encoded, of the
operation the record concerns. Where the enforcement point received a `traceparent` header, the
`trace-id` **MUST** be taken from it rather than generated.

This document defines no correlation identifier of its own. Trace Context is a W3C Recommendation already
emitted by the telemetry infrastructure these enforcement points run inside, and reusing it means an
auditor can join a constraint evaluation, an intent comparison, and a composition record for one action
without any of the three specifications depending on the others.

## 6. Observation Distinguishability

Where distinct actions produce indistinguishable observations at the enforcement point, they are
indistinguishable to any recognizer, however capable. In the formal treatment this is a many-to-one
observation function, and belief ambiguity follows entirely from it.

Enforcement points **MUST** ensure that actions falling under different `action_class` of a governing
declaration emit distinguishable observations.

Enforcement points **SHOULD** treat observation-token collision as a measured property and **SHOULD**
alert when a subject's actions concentrate in colliding tokens.

An agent **MAY** select lower-fidelity paths deliberately — choosing tool surfaces or interfaces whose
telemetry collides with benign activity. This is a rational strategy, not an anomaly. Deployments
**SHOULD** treat a shift toward low-distinguishability paths as significant in itself.

Of everything in this document, this is the requirement most within the deploying party's unilateral
control. Recognition capability is bounded by adversary construction; instrumentation granularity is not.

---

## 7. Security Considerations

**This specification does not detect a determined adversary, and must not be represented as doing so.**
The constructions referenced in Section 1.1 provide an agent with a guaranteed degree of goal ambiguity
that survives full disclosure of its algorithm. What this document provides is attribution: when
divergence *is* observed, it is attributable to a declarant, against a declaration that was in force,
with a signed record.

**Do not standardize the recognizer.** Where a single inference model is mandated, its properties become
public and precomputable, and an adversary plans against it offline. The literature demonstrates exactly
this: an evasion strategy that a human observer notices immediately deceives a specific published
recognizer for the entire duration of the task. Deployments **SHOULD** use recognition models that are
not uniform across the ecosystem, and this document deliberately specifies none.

**Cost-based detection is refuted.** Resource consumption, latency, and path cost are not sound
divergence signals: deceptive action sequences that are simultaneously minimum-cost have been
constructed and demonstrated. A deployment relying on them for divergence detection has a published
bypass.

**Legibility is voluntary and cannot be required as a control.** An agent may be made to declare; it
cannot be made to behave legibly. Legibility and predictability are formally distinct and can be jointly
unsatisfiable, so a specification cannot require both "behave as your declaration predicts" and "make
your purpose inferable early."

**Self-declaration is not evidence.** See Section 3.1. Where the declarant is the subject, the
declaration bounds nothing an adversary respects; its value is that violating it is attributable.

**Amendment is the attack surface.** An adversary that can amend a declaration can retroactively legalize
divergence. Section 4 forbids in-place modification and requires evaluation against the declaration in
force at action time. Deployments **SHOULD** treat `authority` as a high-privilege set and **SHOULD**
alert on amendments that broaden scope shortly before or after a divergence.

**Undeterminable results are a signal.** A subject whose actions are frequently `undeterminable` is
either poorly instrumented or deliberately operating where it cannot be evaluated. Section 5 requires
that these be distinguishable from `in_scope`; deployments **SHOULD** monitor their rate per subject.

---

## 8. Privacy Considerations

A declaration states what an agent is for, and a comparison record states what it did. Together they are
a purpose-and-activity profile of the operator, not only the agent.

Declarations **SHOULD** be distributed only to enforcement points that evaluate against them. Comparison
records **MUST NOT** include action content beyond what identifies the dimension of divergence.

Where the declaration governs an agent acting for a natural person, the `purpose` field may itself be
sensitive; deployments **SHOULD** consider whether it can be omitted from copies distributed to
enforcement points that do not require it.

---

## 9. IANA Considerations

This document requests creation of no registries.

Three were proposed in an earlier revision and each has been withdrawn:

- **Comparison Results** (`in_scope`, `divergent`, `undeterminable`) — closed by construction. An
  evaluation either resolved in scope, resolved out of scope, or did not resolve. There is no fourth
  outcome, and a registry would invite one.
- **Attenuation Modes** (`strict`, `equal`) — obsolete. Strictness is now a boolean in the delegation
  object (Section 3.2) and the predicate semantics belong to
  {{I-D.martherus-authority-attenuation}}.
- **Amendment Notice Modes** (`none`, `notify`, `approve`) — deployment policy rather than an interop
  contract. Two parties do not need to agree on how a declarant notifies its own approvers.

### Media types

This document requests registration of `application/intent-declaration+json` and
`application/intent-declaration+cbor` per {{RFC6838}}, with this document as the specification and the
author as change controller.

---

## 10. Open Items

1. Determine whether the declaration should bind to a token (via a claim or confirmation method) or
   remain a separately resolved artifact. Binding is simpler; separation keeps tokens small and matches
   {{I-D.martherus-claim-resolution}}.
2. Reconcile with RAR {{RFC9396}}: some of `resource` and `action_class` may be expressible as RAR
   authorization details rather than a parallel structure. Investigate before submission.
3. Verify the South et al. characterization against the published paper.
4. Verify the Section 1.1 and Section 7 results against primary sources — the current text derives from a
   secondary survey. Specifically the EXPSPACE-completeness result, the Kerckhoffs-style obfuscation
   guarantee, and the minimum-cost deceptive path construction. The worst-case-distinctiveness theorems
   no longer need verifying: the section that relied on them has been removed (item 5).
5. ~~Decide whether `detection_latency` belongs in a version 00~~ — **removed 2026-08-05.** Its own third
   caution was decisive: the computation producing a detection-latency bound is the computation an
   adversary uses to maximize it, so a declaration member carrying it publishes the adversary's
   objective function. Bounded detection latency remains a sound idea and a deployment may compute one
   privately; it is not something a declaration should carry across a trust boundary.

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

--- abstract

This document profiles the Kinetic Trust Protocol (KTP) as a trust and delegation-chain substrate for two
companion specifications: authority attenuation predicates and portable trust observations.

It exists so that those specifications need not depend on KTP. Each stands alone with no KTP reference of
any kind. A deployment that has chosen KTP uses this profile to bind them together; a deployment that has
not is unaffected.

--- middle

# Introduction

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

## Why this is a separate document

The two companion specifications are intended for a standards process. KTP is published by a single
organization outside any recognized standards body. Binding the base specifications to it would make
their progress contingent on KTP's, and would require every implementer to evaluate KTP whether or not
they use it.

Isolating the dependency here means the reference to KTP appears in exactly one document, which can be
evaluated on its own terms.

## Two quantities, two evaluations

A delegation chain carries two distinct quantities that are easily conflated:

- **Authority** — what the delegate is permitted to do. A static grant, fixed at the hop, narrowable only
  downward. Governed by {{I-D.martherus-authority-attenuation}}.
- **Trust** — how much standing the agent has right now. A dynamic quantity, recomputed from conditions.
  Governed by {{KTP-CORE}} and {{KTP-ENFORCE}}.

Under this profile both are evaluated and **neither substitutes for the other.** An agent may hold
sufficient trust for an action its attenuated authority forbids, and may hold authority for an action its
current trust does not support. An implementation **MUST NOT** derive authority from a trust quantity, or
trust from an attenuation predicate.

# Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they appear in all capitals.

Terms from {{KTP-CORE}} and {{KTP-IDENTITY}} — Trust Proof, trajectory chain, transaction record,
Sponsorship Bond, `E_base`, `E_trust` — are used as defined there.

# Carrying Attenuation in a Trajectory Chain

{{I-D.martherus-authority-attenuation}} Section 4.1 permits its predicates to be carried in an existing
chain, provided the binding names the carrying field and preserves ordering and hash-linking.

Under this profile:

- The attenuation set is carried in a transaction record's action detail object, under an `attenuation`
  member whose value is an array of predicates as defined in
  {{I-D.martherus-authority-attenuation}} Section 5.
- The trajectory chain's `previous_hash` satisfies the hash-linking requirement.
- The chain's append-only property satisfies the ordering requirement.

## Delegation depth MUST NOT be derived from `sequence`

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

## Signatures

KTP-Identity requires that each transaction record carry an agent signature and an Oracle attestation.
{{I-D.martherus-authority-attenuation}} Section 4.3 recommends a delegate signature attesting acceptance
of the stated attenuation.

**These are different signatures serving different purposes and neither satisfies the other.** The Oracle
attestation validates the record's admission to the chain. The delegate signature attests that the
delegate accepted the attenuation.

A deployment requiring delegate accountability **MUST** carry a delegate signature over the attenuation
set in addition to the signatures KTP-Identity requires. An implementation **MUST NOT** treat the Oracle
attestation as satisfying that requirement.

# Trust Proofs as Trust Observations

A KTP Trust Proof {{KTP-CORE}} is a signed, short-lived assertion by a named Trust Oracle. It carries two
quantities that behave differently, and a profile that treats it as one artifact gets the portability
wrong.

`E_trust = E_base × (1 - R)`. `E_base` is standing the agent has accumulated — resilience history,
lineage maturity, and a bounded sponsor contribution. `R` is a risk factor derived from the Context
Tensor: the environment at that enforcement point, at that instant.

**`E_base` is portable. `E_trust` is not.**

## `e_base` as an earned-standing observation

`e_base` is a property of the subject. It was earned by the subject, it does not depend on where the
subject is now, and it is exactly the portable component that
{{I-D.martherus-trust-observation}} Section 5.7 defines `earned_standing` for.

An implementation **MAY** emit `e_base` as an `earned_standing` observation under this mapping:

| Observation member | Trust Proof source |
|---|---|
| `observer` | The `iss` claim (the issuing oracle) |
| `subject` | The `sub` claim |
| `type` | `earned_standing` |
| `value.magnitude` | The `e_base` claim |
| `value.scale` | An identifier for the oracle's E_base scale |
| `value.basis` | Resilience accumulated under KTP's proof-of-resilience model |
| `window_start` / `window_end` | `iat` and `exp` |
| `method` | `direct_enforcement` where the oracle observed directly; otherwise `model_inference` |
| `expires` | `exp` |

`value.scale` is mandatory and **MUST NOT** be omitted on the assumption that "KTP E_base" is a single
scale. Two oracles may weight resilience, lineage, and sponsorship differently within the model's
proportions, so their magnitudes are not comparable and **MUST NOT** be combined.

A Trust Proof **MAY** additionally be consumed as an `attestation_result` observation where the relying
party wants the oracle's appraisal rather than the earned component.

## `e_trust` MUST NOT be carried as an observation

`e_trust` is not a property of the subject. It is the product of the subject's standing and the
*evaluating party's own environmental conditions* at one instant.

An implementation **MUST NOT** emit `e_trust` as an observation of any type, and **MUST NOT** consume a
received `e_trust` as an input to its own authorization decision.

The reason is not the sybilproofness result — it is simpler and stricter. A relying party consuming
another party's `e_trust` would be treating someone else's environment as its own: another site's crowd
density, link saturation, adversarial pressure, and audit posture, silently substituted for the
conditions actually in force where the action is about to happen. That is a category error regardless of
how much the oracle is trusted.

`E_trust` is computed locally, from a portable `E_base` and the evaluating party's own Context Tensor.
That is precisely the division {{I-D.martherus-trust-observation}} Section 6.3 requires: evidence
travels, judgment stays local.

## The sybilproofness result and `E_base`

{{I-D.martherus-trust-observation}} Section 3 forbids an observation carrying a value derived from other
parties' reports about the subject, because no symmetric reputation function over such reports is
sybilproof. `E_base` sits **largely** outside that prohibition. The qualifier is load-bearing and this
section states its limits.

{{KTP-CORE}} Section 5.1 defines:

~~~
E_base = (PoR_score * 0.70) + (Lineage_cap * 0.20) + (Sponsor_contribution * 0.10)

  PoR_score            = f(transaction_count, crisis_ratio, max_friction)
  Lineage_cap          = min(generation * 15, 100)
  Sponsor_contribution = Sponsor_E_base * stake_percentage
~~~

The 70% term is a measurement of the subject's own activity and survival, and the 20% term is structural.
Crisis attestations that raise it require an Oracle signature and a zone-wide crisis, so an agent cannot
manufacture its own adversity. That much is genuinely self-earned, and a fabricated identity inherits
none of it.

**{{KTP-CORE}} Section 5.5.5 adds a term the formula above does not show.** Under GOODHART-004, *"E_base
calculation SHOULD incorporate peer signals that the agent cannot directly control"* — co-transaction
success rate, sponsor reputation, zone endorsements, negative attestations — at a stated weight of
*"10-20% of E_base."*

Those are reports by other parties about the subject. Where a deployment implements GOODHART-004, some of
`E_base` **is** within the class the impossibility result addresses, and this profile does not claim
otherwise.

KTP's own defence is that the signals are chosen for non-manufacturability by the subject: an agent
cannot compel others to transact with it, cannot compel a sponsor to stake on it, and cannot forge a zone
endorsement. That is a real and well-aimed mitigation. It is not the same property as sybil resistance,
which concerns an adversary controlling *multiple* identities rather than a single agent inflating its
own — a colluding population can transact successfully among itself.

**What this profile therefore claims, and no more:**

- `E_base` is predominantly self-earned and is defensible as `earned_standing` under
  {{I-D.martherus-trust-observation}} Section 5.7.
- A relying party **MUST NOT** treat `E_base` as sybil-resistant in the sense the impossibility result
  concerns. It is evidence weighed against the observer's method, not a conclusion inherited.
- A deployment implementing GOODHART-004 **SHOULD** state the peer-signal weight it applies, since the
  strength of the above depends on it. At the upper bound of the stated range, combined with the 10%
  sponsor term, up to 30% of `E_base` is relational rather than self-earned.

Two questions follow that belong to the specification rather than to this profile, and are put to its
author in Section 9. The Section 5.1 formula sums to 1.00 with no term for peer signals, so where the
Section 5.5.5 contribution is seated is not evident. And "sponsor reputation" appears both as a peer
signal in 5.5.5 and as the separate 10% Sponsor Weight in 5.1.

## Newcomer distrust

{{I-D.martherus-trust-observation}} Section 6.2 requires that a subject with no observations be
distinguishable from one with favorable observations.

KTP satisfies this structurally: an agent begins with low `E_base` and raises it by surviving, and
{{KTP-ENFORCE}} places an agent below its lowest tier threshold in a minimal-capability state. A
deployment under this profile **MUST NOT** configure a floor that admits an unproven agent to a tier its
accumulated standing does not support.

# Sponsorship

{{I-D.martherus-trust-observation}} defines a `sponsor_conduct` observation type keyed by a sponsor
identifier, and deliberately does not define how a sponsorship relation is established.

Under this profile, the sponsorship relation is a KTP Sponsorship Bond {{KTP-IDENTITY}}, and the sponsor
identifier used in a `sponsor_conduct` observation **MUST** be the bond's `sponsor_id`.

This profile does not restate the bond's semantics — stake, transfer ratio, or the relation by which a
sponsor's contribution decays as the sponsored agent accumulates its own standing. Those are governed
entirely by {{KTP-IDENTITY}} and an implementation **MUST NOT** derive them from anything in the
companion specifications.

# Enforcement Ordering

{{KTP-ENFORCE}} defines an evaluation sequence: Trust Proof validation, sovereignty veto, tier
eligibility, the A ≤ E constraint, then custom policy.

Authority attenuation is a *custom policy* input in that sequence, not a replacement for any step. A
deployment under this profile **MUST** evaluate composed authority
({{I-D.martherus-authority-attenuation}} Section 6) and **MUST NOT** treat a passing KTP evaluation as
authorizing an action outside the composed authority.

The converse also holds: composed authority permitting an action does not satisfy KTP's constraints, and
an implementation **MUST NOT** bypass them on that basis.

# Security Considerations

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

# Attribution and IPR

The Kinetic Trust Protocol is the work of **Chris Perkins**, New Mexico Cyber Intelligence & Threat
Response Alliance, published under the Apache License, Version 2.0 at
`https://nmcitra.github.io/ktp-rfc/`.

This document profiles that work. It claims no authorship of it, and nothing here should be read as
specifying, extending, or revising KTP itself.

KTP is shared here with attribution by mutual agreement between its author and the author of this
document. Apache 2.0 governs the specification itself; this profile adds nothing to and subtracts nothing
from those terms.

**What remains outstanding is technical, not permissive.** Section 4.4 argues that the sybilproofness
result does not apply to `E_base`, and that argument rests on how KTP derives the resilience component —
a fact about KTP that only its author can settle. If it is wrong, Section 4.4 and the `earned_standing`
mapping in Section 4.1 are both wrong with it. See Open Item 2.

Co-authorship of this profile, or contribution of it to the KTP document set directly, remain open and
would both be preferable to independent publication. Neither is a precondition for it existing.

# Open Items

1. **Where is the Section 5.5.5 peer-signal contribution seated?** {{KTP-CORE}} Section 5.1's formula
   sums to 1.00 across proof of resilience, lineage and sponsor weight, with no term for peer signals.
   Section 5.5.5 states that peer signals SHOULD contribute 10-20% of `E_base`. Does that displace the
   three stated weights, or extend beyond them? Section 4.4's bound depends on the answer.
2. **Is sponsor reputation counted twice?** It appears as a peer signal in {{KTP-CORE}} Section 5.5.5 and
   as the separate 10% Sponsor Weight in Section 5.1.
3. **Determine the normative reference status KTP can actually carry.** As a specification published
   outside a recognized standards body, it may constitute a downward reference requiring justification.
   That question belongs to this document alone — which is why this document exists.
4. **Confirm KTP's versioning and change-control practice** before asserting the pinning guidance in
   Section 7.
5. Decide whether tier thresholds should be restated here. {{KTP-ENFORCE}} publishes them and
   {{KTP-CORE}} does not; restating them would duplicate a value that may change.

# IANA Considerations

This document requests no IANA actions. It profiles existing registries and defines no new values.

--- back

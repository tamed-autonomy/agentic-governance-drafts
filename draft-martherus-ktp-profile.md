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
    organization: Tamed Autonomy
    email: robin@martherus.com
  -
    ins: C. Perkins
    name: Chris Perkins
    organization: New Mexico Cyber Intelligence & Threat Response Alliance
    email: cperkins@nmcitra.org
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
    title: "KTP-Identity: Vector Identity and Trajectory Chains (v1.0.1-provenance)"
    author:
      - ins: C. Perkins
        org: New Mexico Cyber Intelligence & Threat Response Alliance
      - ins: M. Storm
        org: New Mexico Cyber Intelligence & Threat Response Alliance
    target: https://nmcitra.github.io/ktp-rfc/rfcs/ktp-identity/
    date: 2026
  KTP-CORE:
    title: "KTP-Core: Trust Score, Context Tensor, Trust Proof (v1.0.1-provenance)"
    author:
      - ins: C. Perkins
        org: New Mexico Cyber Intelligence & Threat Response Alliance
      - ins: M. Storm
        org: New Mexico Cyber Intelligence & Threat Response Alliance
    target: https://nmcitra.github.io/ktp-rfc/rfcs/ktp-core/
    date: 2026
  KTP-ENFORCE:
    title: "KTP-Enforce (v1.0.1-provenance)"
    author:
      - ins: C. Perkins
        org: New Mexico Cyber Intelligence & Threat Response Alliance
      - ins: M. Storm
        org: New Mexico Cyber Intelligence & Threat Response Alliance
    target: https://nmcitra.github.io/ktp-rfc/rfcs/ktp-enforce/
    date: 2026
informative:
  KTP-VERSIONING:
    title: "KTP Versioning and Release Policy"
    author:
      - ins: C. Perkins
        org: New Mexico Cyber Intelligence & Threat Response Alliance
      - ins: M. Storm
        org: New Mexico Cyber Intelligence & Threat Response Alliance
    target: https://github.com/nmcitra/ktp-rfc/blob/main/VERSIONING.md
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

## Version pinning

This profile is written against KTP at the tag **`v1.0.1-provenance`**, and every structural claim,
section reference, and quoted formula in it was checked against the `rfcs-txt/` sources at that tag.

An implementation of this profile **MUST** pin the KTP revision it is built against, and **MUST NOT**
resolve the references in this document against a branch. `main` is not a version.

Under {{KTP-VERSIONING}}, tags carry the version number, release titles carry the release name, and a
published tag is never moved or deleted. Anything published under a tag stays published; a retraction is
issued as a new release rather than as a deletion. That is what makes pinning meaningful here, and it is
the property this profile depends on rather than any promise of interface stability.

The tag string is **opaque**. `v1.0.1-provenance` carries a descriptive suffix that is not part of a
general scheme, and an implementation **MUST NOT** parse a KTP tag string to derive ordering,
compatibility, or a version number.

Section 4.4 records a revision to {{KTP-CORE}} Section 5.1 that is agreed but not yet released. It is
non-normative and changes nothing about the pin above.

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
lineage maturity, and a bounded sponsor contribution. `R` is a risk factor derived from the evaluating
party's environmental conditions: the environment at that enforcement point, at that instant.

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
proportions, and Section 4.3 requires each deployment to declare its own peer-signal weight, so their
magnitudes are not comparable and **MUST NOT** be combined.

A Trust Proof **MAY** additionally be consumed as an `attestation_result` observation where the relying
party wants the oracle's appraisal rather than the earned component.

### `earned_standing` reports performance, not accountability

{{I-D.martherus-trust-observation}} Section 5.7 defines `earned_standing` as an observer's measurement of
what the subject has demonstrably *done or endured*. The resilience and lineage terms are of that kind.
An attestation of external accountability is not: it asserts that some party is answerable for the
subject, which is a different claim about a different thing, and it is unaffected by anything the subject
has done.

`E_base` is therefore a single scalar of **mixed provenance**, and the mapping above emits it as though
it were of one kind. Where the accountability-derived portion is small this is a tolerable
approximation. Under the revised composition of Section 4.4, where an anchor attestation replaces the
sponsorship term outright, it may not be — a Persistent agent's `E_base` would carry an accountability
claim in a member typed as a performance measurement.

Until that release is published and the question settled, an implementation emitting `e_base` as
`earned_standing` **MUST** record the composition it used in `value.basis` rather than the fixed string
given in the table, so that a relying party can tell what kinds of claim the magnitude combines.

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

`E_trust` is computed locally, from a portable `E_base` and the evaluating party's own environmental
conditions. That is precisely the division {{I-D.martherus-trust-observation}} Section 6.3 requires:
evidence travels, judgment stays local.

## The sybilproofness result and `E_base`

{{I-D.martherus-trust-observation}} Section 3 forbids an observation carrying a value derived from other
parties' reports about the subject, because no symmetric reputation function over such reports is
sybilproof. Deciding which parts of `E_base` that reaches requires **two tests, and they are
independent.** A term must pass both. Neither implies the other, and treating them as one criterion is
the error this section exists to prevent.

**The aggregation test.** {{I-D.martherus-trust-observation}} Section 3.1 forbids *a value aggregating
what other parties say about the subject*, and permits *one named observer's measurement of what the
subject itself has demonstrably done or endured*. The line is aggregation — not the identity of the
reporting party, and not where that party sits. A single named observer's assertion is not a reputation
function at all: there is nothing being aggregated, so there is no function for manufactured identities
to feed.

**The terminator test.** Passing the aggregation test makes a term *admissible*. It does not make it
*mean anything*. A ring of agents attesting for one another satisfies "one named observer, externally
accountable, exposed to loss, able to revoke" at every link and conveys no information whatever. A term
therefore additionally requires that the attesting party's own accountability **terminate, in a finite
and declared number of hops, outside the agent-trust graph** — in law, in physical custody, or in a
named human. A chain that merely continues does not terminate.

**A corollary that binds regardless of either test.**
{{I-D.martherus-trust-observation}} Section 3 also forbids a relying party from aggregating observations
from distinct observers into a single value that is then re-emitted. Individually admissible attestations
therefore become inadmissible on combination. A term satisfied by *one* accountable attestation is
outside the result; the same term computed by combining several attestations is inside it, however
impeccable each attestor is taken separately.

### Applying the tests to published Section 5.1

{{KTP-CORE}} Section 5.1 defines:

~~~
E_base = (PoR_score * 0.70) + (Lineage_cap * 0.20) + (Sponsor_contribution * 0.10)

  PoR_score            = f(transaction_count, crisis_ratio, max_friction)
  Lineage_cap          = min(generation * 15, 100)
  Sponsor_contribution = Sponsor_E_base * stake_percentage
~~~

- **Proof of resilience (70%)** — the issuing oracle's own measurement of the subject's activity and
  survival. One named observer, nothing aggregated: passes the aggregation test. The oracle is
  accountable outside the graph: passes the terminator test. Crisis attestations that raise it require an
  Oracle signature and a zone-wide crisis, so an agent cannot manufacture its own adversity. **Outside
  the result.** A fabricated identity inherits none of it.
- **Lineage (20%)** — structural, derived from the subject's own generation. Not a report by any party.
  **Outside the result.**
- **Sponsor contribution (10%)** — the sponsor is a single named party staking its own standing, so the
  aggregation test passes. The terminator test is **not** answered by published Section 5.1: a sponsor
  may itself be an agent sponsored by an agent, and no bound on sponsorship chain length is stated. A
  deployment **MUST** declare the terminating authority for its sponsorship chains and the maximum number
  of hops before termination. Absent that declaration this term is inside the result.
- **Peer signals ({{KTP-CORE}} Section 5.5.5)** — co-transaction success rate, zone endorsements,
  negative attestations, aggregated across many parties within the system. Fails the aggregation test.
  **Inside the result**, and this profile does not claim otherwise.

KTP's own defence of the peer signals is that they are chosen for non-manufacturability by the subject:
an agent cannot compel others to transact with it, cannot compel a sponsor to stake on it, and cannot
forge a zone endorsement. That is a real and well-aimed mitigation. It is not the same property as sybil
resistance, which concerns an adversary controlling *multiple* identities rather than a single agent
inflating its own — a colluding population can transact successfully among itself.

### The peer-signal weight MUST be declared

{{KTP-CORE}} Section 5.5.5 states that peer signals SHOULD contribute *"10-20% of E_base"*, while the
Section 5.1 formula sums to 1.00 with no term for them. Under this profile the peer-signal contribution
is a **distinct term**. It **MUST NOT** be folded into the resilience, lineage, or sponsorship terms, and
the base terms renormalize in their published proportions to make room for it.

A deployment **MUST** state, in the Trust Proof, the peer-signal weight it applies. This is a MUST rather
than a SHOULD because it is checkable by the relying party and because every claim in this section
depends on it.

Peer signals **MUST** be independent of the base terms. A signal that restates what the composition
already contains adds weight without adding evidence. Sponsor reputation is such a signal: Section 5.1
already multiplies by the sponsor's own `E_base`, so "high-trust sponsors are selective" contributes
nothing the composition has not already counted. It **MUST NOT** be used as a peer signal under this
profile.

### What this profile claims, and no more

- The self-earned and externally-rooted portions of `E_base` sit outside the impossibility result, and
  do so **currently** rather than only at issuance.
- The portion inside the result is the **declared peer-signal weight**. Once declared, that figure is
  exact and a relying party need not reason about a bound.
- `E_base` is defensible as `earned_standing` under {{I-D.martherus-trust-observation}} Section 5.7 to
  the extent of its terms that pass both tests.
- A relying party **MUST NOT** treat `E_base` as sybil-resistant in the sense the impossibility result
  concerns. It is evidence weighed against the observer's method, not a conclusion inherited.

Where a deployment declares no peer-signal weight and no sponsorship terminator, the relational portion
of `E_base` is bounded above by the 20% upper end of the Section 5.5.5 range plus the 10% sponsor term:
**up to 30%**. That bound is what a relying party must assume in the absence of the declarations this
section requires, and is the reason they are required.

## The composition is being revised

This subsection is **non-normative**. Nothing in it changes the pin in Section 2.1 or the requirements
above, which are stated against {{KTP-CORE}} as published at `v1.0.1-provenance`.

Four defects in published Section 5.1 are agreed with its author, and will be corrected in a subsequent
KTP release rather than by amendment under the existing tag:

1. **The lineage term contradicts itself.** The prose treats generation as a ceiling on `E_base` — 40
   Tethered, 70 Divergent, unbounded Persistent. The formula uses `Lineage_cap = min(generation * 15,
   100)` as an *additive* term at 20%. The values do not correspond, and "unbounded" contradicts the
   `min`. Resolution: the ceiling reading governs and the additive term is removed. Maturity buys
   headroom rather than points — an agent gains permission to accumulate standing, not standing for
   having advanced.
2. **The sponsorship term disappears silently.** The 10% weight applies "For Tethered agents"; past
   generation 2 it is zero, the weights sum to 0.90, and nothing states what becomes of the remainder.
   Read literally, a Persistent agent cannot exceed 90 — which puts God Mode ({{KTP-ENFORCE}} Section
   5.1.1, `E_trust >= 95`) permanently beyond the most mature class in the model, and makes
   {{KTP-ENFORCE}} Section 9.5's own worked example at `E_base = 98`, together with its `E_base > 95`
   taxation branch, unreachable.
3. **Peer signals have no seat.** Resolved as required above: a distinct, declared term.
4. **Sponsor reputation is counted twice.** Resolved as required above: removed from the peer-signal
   set.

The correction to (2) is the one that matters most to this profile. The sponsorship bond does not
vanish at release; it **converts**. While tethered, a sponsor stakes standing it can lose against the
agent's future conduct. At release that stake ends — a graduated agent should not hold its sponsor
hostage indefinitely — and what replaces it is a *current* attestation from an externally accountable
party: exposed to loss, revocable, and liable for the accuracy of the claim rather than for whatever the
agent does next.

The completed-tether record becomes provenance. It is not the anchor. A clean handshake from years ago
says nothing about who is accountable now, and a credential true at issuance presented as current
standing is precisely the failure this profile guards against elsewhere.

When that release lands, the required declarations above become computable rather than bounded, and the
30% fallback bound ceases to apply. Whether the resulting anchor term is emittable as `earned_standing`
is an open question — see Section 4.1.1 and Section 9.

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
control, and KTP carries no formal interface-stability promise. What it does carry is a published release
policy {{KTP-VERSIONING}}: tags are never moved or deleted, and retractions are issued as new releases
rather than as deletions. That makes a pinned reference durable without making the interface stable.

Implementations **MUST** pin as Section 2.1 requires and **MUST NOT** assume this profile remains
accurate across KTP versions. The revision described in Section 4.4 is a live example: it changes three
of the four terms of the composition Section 4.3 reasons about, and an implementation that resolved these
references against `main` rather than `v1.0.1-provenance` would silently acquire it.

**Declarations are load-bearing, and their absence is not benign.** Section 4.3 requires a deployment to
declare its peer-signal weight and its sponsorship terminator. A deployment that omits them does not
thereby become safe — it becomes unassessable, and a relying party **MUST** fall back to the 30% bound
rather than assume the omitted terms are zero. Implementations **SHOULD** treat a Trust Proof carrying
no declared peer-signal weight as materially weaker evidence than one carrying a declared weight of 20%.

**Attestation rings.** The terminator test in Section 4.3 exists because external accountability is
locally checkable and globally forgeable. Each link in a ring of mutually attesting agents can present a
named, loss-exposed, revocable attestor, and a verifier checking only the immediate attestor will pass
every one of them. A verifier **MUST** follow the accountability chain to its declared terminator, and
**MUST** reject a chain that exceeds the deployment's declared hop bound or that revisits a party.

# Attribution and IPR

This document binds two independently authored bodies of work, and is co-authored across the seam.

The **Kinetic Trust Protocol** is the work of **Chris Perkins** and **Mike Storm**, published by the New
Mexico Cyber Intelligence & Threat Response Alliance under the Apache License, Version 2.0 at
`https://nmcitra.github.io/ktp-rfc/`.

The companion specifications this profile binds KTP to —
{{I-D.martherus-authority-attenuation}} and {{I-D.martherus-trust-observation}} — are the work of
**Robin Martherus** under Tamed Autonomy.

Neither party claims authorship of the other's work, and nothing here should be read as specifying,
extending, or revising KTP itself. The readings of KTP in Sections 3 and 4 were arrived at by
implementing against the specification and are endorsed by its author; the corrections recorded in
Section 4.4 arose from that reading and are agreed, but they are changes to KTP that KTP will make, not
changes this document makes.

Apache 2.0 governs the KTP specification itself. This profile adds nothing to and subtracts nothing from
those terms.

# Open Items

1. **Determine the normative reference status KTP can actually carry.** As a specification published
   outside a recognized standards body, it may constitute a downward reference requiring justification.
   That question belongs to this document alone — which is why this document exists. A narrow draft is
   being prepared covering the ground this profile depends on: the definition of `E_base`, the
   portability boundary, the declaration requirements, the comparability rule, and the sybilproofness
   posture stated by KTP's author rather than inferred here. If filed, the references in Section 2 become
   a Datatracker citation rather than a repository URL. It is a citation upgrade, not a dependency, and
   does not gate this document.
2. **Whether the anchor term can be carried as `earned_standing`.** Section 4.1.1 states the problem:
   `earned_standing` is defined as a measurement of what the subject did or endured, and an accountability
   attestation is not that. Under the revised composition of Section 4.4 the accountability-derived
   portion is no longer small. Three positions are possible — widen `earned_standing`, split the mapping
   so the anchor travels as `attestation_result`, or define a new observation type for current
   accountability. The third is the most honest and the most expensive.
3. **Whether the sponsorship hop bound should be a fixed number rather than a declared one.** Section 4.3
   requires a deployment to declare its terminator and hop count. A declared bound is checkable but
   permits a deployment to declare a useless one; a fixed bound is stronger but is a number this profile
   cannot justify from either specification.
4. Decide whether tier thresholds should be restated here. {{KTP-ENFORCE}} publishes them and
   {{KTP-CORE}} does not; restating them would duplicate a value that may change.

# IANA Considerations

This document requests no IANA actions. It profiles existing registries and defines no new values.

--- back

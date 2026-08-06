---
title: "Portable Trust Observations for Autonomous Agents"
abbrev: "Trust Observations"
docname: draft-martherus-trust-observation-00
category: exp
ipr: trust200902
area: Security
workgroup: Independent Submission
keyword: [trust, reputation, attestation, autonomous agents]
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
informative:
  RFC6838:
  RFC9334:
  I-D.martherus-intent-scope:
    title: "Intent Scope Declarations for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
  I-D.martherus-layer-handoff:
    title: "Cooperative Enforcement and Decision Composition for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
  I-D.martherus-claim-resolution:
    title: "Multi-Issuer Claim Resolution for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
  I-D.martherus-ktp-profile:
    title: "Kinetic Trust Protocol Profile for Agentic Governance Interchange"
    author:
      - ins: R. Martherus
    date: 2026
---

--- abstract

Systems that evaluate autonomous agents increasingly compute a notion of trust from behavioral history.
Those computations are proprietary, their inputs are not portable, and their outputs are scalar scores
whose meaning does not survive leaving the system that produced them.

This document defines a format for *trust observations*: signed, typed, attributable statements by a
named observer about a named subject over a stated window. It deliberately does not define a trust score,
a scoring algorithm, or a portable reputation value. A relying party computes its own conclusions from
observations it chooses to accept, relative to its own trust root.

--- middle

# Introduction

The intuition behind portable trust is that an agent which has behaved well under one party's
observation should not arrive at the next party with no history. The intuition is sound. The obvious
implementation — a portable trust score — is not available, and this document does not attempt it.

## Why not a score

Cheng and Friedman established that no symmetric reputation function is sybilproof: for any reputation
function meeting reasonable symmetry conditions, an adversary can manufacture identities to obtain an
arbitrarily favorable value. This is an impossibility result, not an engineering difficulty. No amount of
additional computation, model capability, or cryptographic machinery changes it.

Friedman and Resnick established the complementary result for newcomers: where identities are cheap,
no equilibrium outperforms distrusting newcomers. An agent with no history cannot be safely treated as
better than an agent that discarded its history.

Edelman's measurement of third-party certification is the empirical companion: certified sites were more
than twice as likely to be untrustworthy as uncertified ones. A signal whose issuer bears no cost for
being wrong does not merely fail to help — it inverts, becoming a marker of the population that sought
cover.

These three results jointly determine this document's design:

1. **No global score.** Trust is computed by a relying party, relative to its own trust root, from
   observations it has decided to accept. This specification defines no global trust value, and no
   observation may carry one derived from other parties' reports about the subject. What an observer may
   report is its own measurement — including, where a trust model produces one, a scalar measure of what
   the subject has itself earned (Section 5.7). The distinction is drawn in Section 3.
2. **Newcomer distrust is a designed property.** An agent with no observations is not "neutral." Section
   6.2 requires that absence of history be representable and distinguishable from good history.
3. **Issuer accountability is in the format.** Every observation names its observer and is signed
   (Section 4). An observation that proves wrong is attributable to the party that made it.

## What is standardized

The division is: **compete on how you compute, standardize what you emit.**

A behavioral detection vendor's model is its product. The statement "this subject operated within its
declared scope for fourteen consecutive days, observed at this enforcement point, by this method" is not
a product — it is an input that every other layer needs and that no other layer can currently consume.

## Relationship to remote attestation

RATS {{RFC9334}} defines an architecture for evidence about a system's composition and state, appraised
against policy to produce attestation results. Trust observations are complementary and distinct: RATS
evidence concerns *what a system is*; a trust observation concerns *what a subject did over time*.

An implementation **MAY** carry attestation results as an observation input, and Section 5.5 defines an
observation type for that purpose. This document does not redefine attestation.

# Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they appear in all capitals.

**Observation:** A signed statement by an observer about a subject's behavior over a window.

**Observer:** The entity that made and signed the observation, and is accountable for it.

**Subject:** The agent, workload, or principal the observation concerns.

**Trust Root:** The set of observers a relying party has decided to accept, with the weight it assigns
each. Local to the relying party. Not portable.

**Window:** The bounded time interval an observation covers.

## Artifact state vocabulary

Used consistently across this document set. Each document defines its own *consequences*; the terms mean
the same thing everywhere.

| Term | Meaning |
|---|---|
| `absent` | No artifact exists or none was found |
| `unavailable` | An artifact exists but could not be retrieved, or verification could not be *attempted* — key unavailable, algorithm unsupported, endpoint unreachable |
| `untrusted` | Retrieved and well-formed, but its issuer is outside the relying party's accepted set |
| `invalid` | Verification was attempted and **failed** — signature does not verify, or content is malformed |
| `expired` | Retrieved and valid, but past its stated validity |

`unavailable` **MUST NOT** be reported or treated as `absent`.

# Design Constraints

Stated normatively because implementations have repeatedly violated them.

- An observation **MUST NOT** carry a value derived from other parties' reports about the subject.
- An observation **MUST** name its observer.
- An observation **MUST** state the window it covers.
- An observation **MUST** state the method by which it was produced.
- A relying party **MUST NOT** treat an observation from an observer outside its trust root as carrying
  any weight, regardless of the observation's signature validity.
- A relying party **MUST NOT** aggregate observations from distinct observers into a single value that is
  then re-emitted as an observation. Aggregation is a local computation and its output is not portable.

## What is and is not forbidden

The first and last constraints are the sybilproofness result expressed as protocol rules, and the line
they draw is narrower than "no numbers."

**Forbidden: a value aggregating what other parties say about the subject.** That is a reputation
function in the sense the impossibility result addresses. An adversary who can manufacture identities can
manufacture the reports that feed it, and no symmetry-preserving function resists that. An aggregate that
circulates becomes a score, and a score that circulates can be manufactured.

**Permitted: one named observer's measurement of what the subject itself has demonstrably done or
endured.** That is not a reputation function. It reports the observer's own observation of the subject,
and a manufactured identity inherits none of it — a newly created agent starts with nothing and must
accumulate its own, at the same cost as any other. Standing up a thousand identities costs a thousand
times as much, which is dues-paying rather than a sybil advantage, and dues-paying is the one equilibrium
that outperforms distrusting newcomers where identity is cheap.

Such a value may be a scalar. `earned_standing` (Section 5.7) is the type for it.

Two constraints follow and are not relaxed. The value remains meaningful only relative to its observer
and that observer's method, so two observers' figures are **not** comparable and **MUST NOT** be
combined; and it is evidence a relying party weighs, never a conclusion it inherits.

# Observation Object

A JSON {{RFC8259}} or CBOR {{RFC8949}} object.

| Member | Type | Required | Description |
|---|---|---|---|
| `observer` | string | yes | Identifier of the accountable observer |
| `subject` | string | yes | Identifier of the observed subject |
| `type` | string | yes | Observation type (Section 5) |
| `window_start` | string | yes | RFC 3339 |
| `window_end` | string | yes | RFC 3339 |
| `value` | varies | yes | Type-specific; see Section 5 |
| `method` | string | yes | How the observation was produced (Section 4.1) |
| `sample_size` | integer | no | Number of events the observation summarizes |
| `vantage` | string | no | Where the observation was made (enforcement point class) |
| `expires` | string | conditional | RFC 3339; after which the observer no longer stands behind it. REQUIRED for observations published to a resolution endpoint (Section 4.2) |

Observations **MUST** be signed with JOSE {{RFC7515}} or COSE {{RFC9052}}, **MUST** carry an explicit
algorithm identifier, and **MUST** support algorithm migration without changing observer identifiers.

Observations may be consulted years after issuance — an agent's operating history is exactly the kind of
claim whose value increases with age. Implementations **SHOULD** support post-quantum signature
algorithms as they are registered.

## Method

`method` states how the observation was produced, at a granularity sufficient for a relying party to
decide whether to accept it. Initial values:

- `direct_enforcement` — the observer sat in the action path and observed outcomes directly
- `log_analysis` — derived from records after the fact
- `sampled` — derived from a sample rather than the full population
- `model_inference` — produced by a model whose output is not individually verifiable
- `self_reported` — reported by the subject

`self_reported` exists so that self-report is *representable and marked*, not so it is trusted. A relying
party **MUST NOT** accept a `self_reported` observation as evidence for any property the subject has an
incentive to misstate.

## Expiry

`expires` is OPTIONAL for an observation held and evaluated locally by the observer that made it, where
the holder knows its own retention policy.

`expires` is **REQUIRED** for any observation an issuer publishes for retrieval by another party. An
observation with no stated expiry cannot be safely cached, and an uncacheable artifact on a decision path
will be either re-fetched on every evaluation or cached for an interval the observer never sanctioned.

Do not confuse the two intervals. `window_start`/`window_end` state the period the observation *covers*;
`expires` states how long the observer *stands behind it*. A relying party **MUST NOT** treat window end
as expiry — an observation of last month's behavior may remain the observer's current best statement.

# Observation Types

## `intent_compliance`

Whether the subject's actions remained within a declared scope over the window. `value` is an object with
`in_scope` and `out_of_scope` counts and an optional `violations` array of references.

This type is the observable half of the declared-versus-done pair. A purpose declaration that is never
compared against behavior will be falsified at scale; this observation type is how the comparison
becomes portable. See {{I-D.martherus-intent-scope}}.

## `behavior_under_stress`

The subject's conduct during periods of degraded context, elevated load, resource contention, or partial
failure. `value` is an object with `stress_episodes`, `deviations`, and an optional characterization.

Distinguished from ordinary compliance because conduct under normal conditions is a weak predictor of
conduct under abnormal ones, and because an adversary can arrange normal conditions.

## `sponsor_conduct`

The observer's assessment of how subjects sponsored by a given sponsor have behaved. `value` names the
sponsor and carries the observation over its sponsored population.

**This document does not define the sponsorship relation, and does not need to.** The sponsor is an
opaque identifier: a stable name for a party that has accepted some accountability for a population of
subjects. How that acceptance is established, what is staked, and whether the stake decays are matters
for whatever mechanism creates the relation — a delegation chain, a contract, a registry — and are out of
scope here.

What is in scope is the conduct of that population, which is observable without knowing how the relation
was formed.

An implementation **MUST NOT** treat a `sponsor_conduct` observation as establishing that a sponsorship
exists, and **MUST NOT** infer the terms of a sponsorship from one. The observation asserts only that the
observer attributes the described conduct to subjects it associates with the named sponsor.

Where a relying party has no mechanism for establishing sponsorship relations, this observation type is
not usable and **SHOULD** be omitted rather than populated with an inferred sponsor.

Sponsorship matters because it is the structural answer to Friedman and Resnick: where identity is cheap,
what distinguishes a genuine newcomer from a whitewashed re-entrant is a party willing to bear cost for
it. This document contributes the evidence that the cost was warranted — not the mechanism that imposes
it.

{{I-D.martherus-ktp-profile}} defines one binding, in which the sponsor identifier is a KTP Sponsorship
Bond's `sponsor_id`. That binding is informative here; nothing in this document requires it.

## `anomaly_pressure`

Frequency and character of anomalous events attributed to the subject over the window, as assessed by
the observer's own detection. `value` is an object with `events` and an optional `categories` map.

`anomaly_pressure` is explicitly *not* a risk score. It is a count of what one observer's detection
flagged, and its meaning is inseparable from that observer's detection quality — which is precisely why
`observer` and `method` are mandatory.

## `attestation_result`

An appraisal result from a remote attestation process {{RFC9334}}. `value` carries the result and the
appraising entity.

## `earned_standing`

A scalar measure of standing the subject has itself accumulated, as computed by the observer. `value` is
an object carrying `magnitude`, the observer's `scale` identifier, and the `basis` on which it was
derived.

This is the type for the portable component of a trust model whose output separates *what the subject has
earned* from *what current conditions permit*. The earned component is a property of the subject and
travels with it. The conditional component is computed from the evaluating party's own environment and
does not travel — a receiving party consuming another party's conditional figure would be treating
someone else's circumstances as its own.

An `earned_standing` observation **MUST NOT** be derived from other parties' reports about the subject
(Section 3). It reports what the observer measured the subject to have withstood, completed, or
maintained.

`scale` is mandatory because magnitudes from different observers are not comparable. A relying party
**MUST NOT** compare or combine `earned_standing` magnitudes across observers, or across scales from one
observer, and **MUST NOT** treat a magnitude as meaningful without the scale that defines it.

`basis` states what was measured — survival under adversarial conditions, volume of completed in-scope
operations, duration of continuous compliant operation. A relying party unable to interpret a `basis`
**MUST** treat the observation as `untrusted` rather than substituting a default reading.

## `no_history`

An explicit assertion that the observer has no observations of this subject for the stated window.

This type exists because absence of evidence must be expressible. Section 6.2 requires that a relying
party distinguish "no history" from "good history"; that is only possible if an observer can say so.

# Relying Party Behavior

## Trust root

A relying party **MUST** maintain an explicit set of accepted observers. Observations from observers
outside that set **MUST** be treated as `untrusted` (Section 2.1) and **MUST NOT** carry weight.

`untrusted` is distinct from `absent`. A relying party **SHOULD** retain the fact that an untrusted
observation was offered; a subject presenting observations exclusively from observers outside the
relying party's trust root is itself informative.

A relying party **MUST NOT** derive its trust root transitively from another party's trust root without
explicit configuration. Transitive acceptance is how a sybil population enters an otherwise sound trust
root.

## Newcomers

A subject for which a relying party holds no accepted observations **MUST NOT** be treated as equivalent
to a subject with favorable observations.

Implementations **MUST** be able to distinguish, in their decision inputs, the states: no observations
held; observations held and favorable; observations held and unfavorable; observations held but expired.

Collapsing the first into any other is the failure mode that makes cheap identity profitable.

## Computation is local

This document defines no algorithm for combining observations. A relying party's method for weighting
observers, discounting age, and reconciling conflicting observations is local policy and out of scope.

Where a relying party's conclusion is used as an input to a decision, the conclusion **SHOULD** be
carried as an annotation within a composition record rather than re-emitted as an observation. See
{{I-D.martherus-layer-handoff}} Section 3.1.

# Relationship to Prior Work

Reputation systems have been studied and deployed for three decades. The deployed successes are
overwhelmingly *closed* systems — a single operator, a single population, a single computation, with the
operator bearing the cost of manipulation. Portable, cross-domain reputation has not succeeded, and the
sybilproofness and cheap-identity results explain why.

This document does not attempt to solve portable reputation. It moves the portability boundary: what
crosses domains is the *evidence*, attributed and signed, and what stays local is the *judgment*. That is
a weaker claim than portable trust and it is the strongest claim the literature permits.

Verifiable credential formats supply signed claim carriage and are a plausible alternative encoding for
Section 4. They do not supply an observation type system, an observer accountability model, or the
relying-party rules of Section 6, which is the substance of this document.

# Security Considerations

**Sybil manufacture.** An adversary controlling many identities can generate many observations. The
defense is not in the format — it is Section 6.1's requirement that relying parties accept only observers
in an explicit trust root, and Section 6.3's prohibition on transitive trust-root derivation. Deployments
**MUST NOT** admit observers automatically.

**Collusion.** Observers in a relying party's trust root may collude to issue favorable observations.
Attribution (Section 4) makes collusion detectable after the fact but does not prevent it. Relying
parties **SHOULD** weight observers by independently assessed quality and **SHOULD** monitor for observers
whose observations are systematically more favorable than peers observing the same subjects.

**Whitewashing.** A subject with unfavorable history can abandon its identifier and return as a newcomer.
Section 6.2 is the mitigation: newcomers are not advantaged relative to subjects with unfavorable
history, so discarding history gains nothing. Deployments that treat newcomers permissively defeat this.

**Observation laundering.** A party may aggregate observations and re-emit the aggregate as its own
observation, converting a local judgment into a portable score. Section 3 forbids this. Relying parties
**SHOULD** reject observations whose `method` indicates aggregation over other observers.

**Selective disclosure by the subject.** Where a subject presents its own observations, it will present
favorable ones. Relying parties **SHOULD** obtain observations from observers directly rather than from
the subject, and **MUST** treat a subject-presented observation set as incomplete by default.

**Expiry as an attack.** An observer that declines to renew an unfavorable observation can silently
rehabilitate a subject. Relying parties **SHOULD** retain the fact that an unfavorable observation existed
after it expires, even when they cease to weight its content.

# Privacy Considerations

Observations about an agent are frequently observations about the human or organization on whose behalf
it acts, and an observation set assembled across domains is a behavioral profile.

Relying parties **SHOULD** request only the observation types required for the decision at hand.
Observers **SHOULD NOT** include event-level detail where a summary suffices, and **MUST NOT** include
content of the subject's actions in an observation body.

Where the subject is an agent acting for a natural person, an assembled observation set may constitute
personal data under applicable law even where no single observation does. Deployments should evaluate
the assembled set before transmitting it across a domain boundary.

# IANA Considerations

This document requests creation of two registries.

**Trust Observation Types** — initial values `intent_compliance`, `behavior_under_stress`,
`sponsor_conduct`, `anomaly_pressure`, `attestation_result`, `earned_standing`, `no_history`.
Registration policy:
Specification Required.

**Trust Observation Methods** — initial values `direct_enforcement`, `log_analysis`, `sampled`,
`model_inference`, `self_reported`. Registration policy: Specification Required.

## Registration template

Each registration **MUST** supply:

| Field | Description |
|---|---|
| Value | The identifier being registered |
| Description | What it means, in one or two sentences |
| Specification | Reference to the document defining it |
| Change controller | The party who may modify or deprecate the registration |
| Contact | Email address for questions |

## Designated expert guidance

The designated expert **SHOULD** approve a registration when the value names a genuinely distinct concept
whose meaning is unambiguous from the supplied description, and **SHOULD** reject one that is a synonym
of an existing value, a deployment-local policy knob, or a value whose semantics depend on a single
vendor's implementation. Where a proposed value overlaps an existing one, the expert **SHOULD** ask
whether extending the existing description would serve as well.

Additionally, for this document's registries the expert **SHOULD** reject any proposed observation type
whose value aggregates other parties' reports about the subject, however named — Section 3 forbids such
values and a registry is the most likely route by which one would re-enter. A type whose value is a
scalar measurement by the registering observer of the subject's own conduct is **not** within that
prohibition; see `earned_standing`.

## Media types

`application/trust-observation+json` and `application/trust-observation+cbor`, registered per
{{RFC6838}} with this document as the specification and the author as change controller.

# Open Items

1. Decide whether to define a Verifiable Credentials binding as an alternative encoding, or to state
   explicitly that VC carriage is out of scope.
2. ~~`confidence` is under-specified~~ — **removed 2026-08-05.** A bare 0.0–1.0 number whose meaning
   differed per observer, and the most likely route by which a score-like value would re-enter contrary
   to Section 3. An observer needing to express uncertainty does so through `method` and `sample_size`,
   which are interpretable.
3. ~~Determine whether `sponsorship_stake` belongs here~~ — **resolved.** This document observes sponsor
   conduct only, keyed by an opaque sponsor identifier (Section 5.3). It defines no sponsorship relation.
4. Consider whether observers should be required to publish their retention and revocation policy, and
   whether an observation revocation mechanism is needed or whether `expires` is sufficient.
5. Confirm the Cheng & Friedman and Friedman & Resnick citations against the primary papers before
   submission; the characterizations here derive from a secondary survey.
6. ~~`expires` optional here but required by claim-resolution~~ — **resolved.** Section 4.2 makes
   `expires` REQUIRED for any observation published for retrieval by another party, and OPTIONAL only
   for locally held observations. This matches {{I-D.martherus-claim-resolution}} Section 5.2.
7. ~~Decide whether to define a profile for consuming KTP Trust Proofs~~ — **resolved.** That profile is
   {{I-D.martherus-ktp-profile}}, which maps Trust Proofs onto this document's observation model and
   restates the Section 3 prohibition on portable scores. It is informative here; this document is
   complete without it.

--- back

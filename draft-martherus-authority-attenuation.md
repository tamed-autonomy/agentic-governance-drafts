---
title: "Authority Attenuation Predicates for Delegation Chains"
abbrev: "Authority Attenuation"
docname: draft-martherus-authority-attenuation-00
category: exp
ipr: trust200902
area: Security
workgroup: Independent Submission
keyword: [delegation, attenuation, authorization, autonomous agents]
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
  RFC9943:
  RFC8693:
  I-D.martherus-normative-constraint:
    title: "Normative Constraint Exchange for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
  I-D.martherus-intent-scope:
    title: "Intent Scope Declarations for Autonomous Agents"
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
  KTP-IDENTITY:
    title: "KTP-Identity: Vector Identity and Trajectory Chains"
    author:
      - ins: C. Perkins
        org: New Mexico Cyber Intelligence & Threat Response Alliance
    target: https://nmcitra.github.io/ktp-rfc/rfcs/ktp-identity/
    date: 2026
---
Autonomous agents delegate to other agents, which delegate further. Where a delegation chain exists,
each hop should narrow the authority available to the delegate. Existing capability systems enforce
attenuation cryptographically but leave the meaning of each narrowing application-defined, so an
attenuation minted in one domain cannot be evaluated in another.

This document defines a registered vocabulary of **authority attenuation predicates** — the dimensions
along which permission narrows across a delegation hop — together with the monotonicity and verification
rules that make a chain evaluable.

Its subject is the meaning of a hop, not the construction of a chain. It defines no identity model and no
trust model, and its predicates are intended to be carried in whatever append-only chain a deployment
already operates. A minimal chain binding is provided (Section 4.2) so the document is implementable on
its own.

# Introduction

Token exchange {{RFC8693}} narrows a credential across an exchange but produces no evaluable record of
the delegation relationship. Capability systems — macaroons and their successors — carry attenuation in
the credential itself and enforce it cryptographically without issuer consultation. That construction is
sound.

**The gap is semantic, not cryptographic.** A macaroon's caveats are meaningful to the system that minted
them and opaque to any other. Two organizations can each attenuate correctly and be unable to evaluate
each other's attenuations. The envelope is standardized; the predicates inside it are not.

This document standardizes the predicates.

## Scope: authority, not trust

Delegation chains carry two distinct quantities that are easily conflated:

- **Trust** — how much standing flows to a delegate, and how it decays as the delegate accumulates its
  own history. This is a *dynamic* quantity, recomputed from conditions.
- **Authority** — what the delegate is permitted to do. This is a *static* grant, fixed at the hop and
  narrowable only downward.

**This document specifies authority attenuation only.** It defines no trust quantity, no trust ceiling,
no trust scale, and no sponsorship relation. Trust models for delegated agents exist and are under active
development; this document is deliberately independent of which one a deployment uses.

A deployment operating both evaluates two independent questions at each hop: *is this action within the
attenuated authority* (this document) and *does the agent have sufficient standing right now* (its trust
model). **Neither answer substitutes for the other**, and an implementation **MUST NOT** derive authority
from a trust quantity or trust from an attenuation predicate.

{{I-D.martherus-ktp-profile}} binds this document to one such trust model. It is informative here: nothing
in this specification requires it, and an implementation conforming to this document alone is complete.

## Renamed from "delegation lineage"

An earlier revision of this document was titled *Delegation Lineage Records* and defined a chain format
of its own. That scope overlapped KTP-Identity's trajectory chains, which already specify append-only
records with `chain_id`, `sequence`, `previous_hash`, and dual signature. The chain is not the
contribution; the predicate vocabulary is. The title now says so.

"Provenance" is likewise avoided. It has established meanings in supply-chain attestation and in model
training attestation — KTP-Provenance, for instance, concerns training data consent and knowledge debt,
an unrelated subject.

# Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they appear in all capitals.

**Hop:** One delegation event: a delegator, a delegate, and the attenuation applied.

**Delegator / Delegate:** The parties to a hop.

**Chain:** An ordered, append-only sequence of hops from a root to a subject.

**Attenuation Set:** The predicates applied at one hop.

**Composed Authority:** The intersection of every attenuation set along a chain.

**Root:** The origin of a chain, holding authority not derived from a prior hop.

## Artifact state vocabulary

The following terms are used consistently across this document set. Each document defines its own
*consequences*; the terms themselves mean the same thing everywhere.

| Term | Meaning |
|---|---|
| `absent` | No artifact exists or none was found |
| `unavailable` | An artifact exists but could not be retrieved, or verification could not be *attempted* — key unavailable, algorithm unsupported, endpoint unreachable |
| `untrusted` | Retrieved and well-formed, but its issuer is outside the relying party's accepted set |
| `invalid` | Verification was attempted and **failed** — signature does not verify, or content is malformed |
| `expired` | Retrieved and valid, but past its stated validity |

`unavailable` **MUST NOT** be reported or treated as `absent`. A system that treats an unreachable
component as silent can be attacked by making it unreachable.

# What This Document Is Not

Stated prominently because the shape invites misreading.

This specification defines signed records held by the parties that produce and rely on them. It does
**not** define or require a distributed ledger, a replicated state machine, a consensus protocol, a chain
of blocks, mining, any token or asset, or a globally shared append-only structure.

"Append-only" here means a hop record, once signed, is not modified, and a chain extends only by adding
records whose predecessors are referenced by hash. That property comes from ordinary hash-chaining and
signatures. No distributed agreement is required, because each record is verifiable against its signer's
key by anyone holding it.

Deployments requiring third-party verifiable non-equivocation over chains may use SCITT {{RFC9943}} as a
transparency substrate. That is an optional deployment choice, not a dependency. See Section 11.

# Carriage

This document defines predicates, not a chain. Predicates are carried in a chain record's attenuation
field.

## Binding to an existing chain

Where a deployment already operates a delegation chain, the attenuation set is carried in that chain's
records. A binding **MUST** specify which field carries the set and **MUST** preserve the ordering and
hash-linking properties Section 6 requires.

One such binding — to KTP-Identity trajectory chains — is defined in {{I-D.martherus-ktp-profile}}.
Others may be defined by any specification meeting the requirements of this section.

## Minimal standalone binding

For deployments without an existing chain, this document defines a minimal hop record so that it can be
implemented without adopting another specification.

| Member | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Stable hop identifier |
| `prior` | string | conditional | Hash of the preceding hop; absent only at a root |
| `delegator` | string | yes | Principal delegating |
| `delegate` | string | yes | Principal receiving |
| `depth` | integer | yes | Hops from root; root is 0 |
| `attenuation` | array | yes | Attenuation set (Section 5) |
| `purpose_ref` | string | no | Intent declaration governing the delegate |
| `not_before` / `not_after` | string | yes | RFC 3339 validity bounds |
| `revocation` | object | no | Method (Section 7) |

Records are JSON {{RFC8259}} or CBOR {{RFC8949}}.

## Signatures

A hop record **MUST** be signed by the delegator.

A hop record **SHOULD** additionally be signed by the delegate. A delegate signature attests that the
delegate accepted the stated attenuation; a record signed only by the delegator records what was offered,
not what was accepted. Deployments requiring accountability at the delegate **MUST** require it.

**A hop record MAY carry additional signatures serving other purposes.** KTP-Identity trajectory chains,
for example, require an agent signature and an Oracle attestation — a different pair, validating the
record's admission to the chain rather than the delegate's acceptance of attenuation. The two
requirements are orthogonal and a record may satisfy both. Implementations **MUST NOT** treat the
presence of an Oracle or other third-party signature as satisfying the delegate-signature requirement,
and **MUST NOT** treat a delegate signature as satisfying a chain's own admission requirements.

Signatures use JOSE {{RFC7515}} or COSE {{RFC9052}}, **MUST** carry explicit algorithm identifiers, and
**MUST** support algorithm migration without altering hop identifiers. A chain may be evaluated years
after its early hops were minted; implementations **SHOULD** support post-quantum algorithms as they are
registered, and **SHOULD** support counter-signing an existing record with a newer algorithm without
altering the original record or its hash.

# Attenuation Predicates

The registered vocabulary is the contribution of this document.

| Predicate | Narrows | Value type |
|---|---|---|
| `resource` | Resources reachable | set |
| `action_class` | Action classes permitted | set |
| `data_classification` | Data classes handleable | set |
| `time` | Validity window | interval |
| `depth` | Remaining permitted hops | integer |
| `fanout` | Permitted direct delegates | integer |

Set-valued predicates narrow by subset. Interval-valued predicates narrow by containment.
Integer-valued predicates narrow by non-increase.

`action_class` is the same concept named identically in {{I-D.martherus-normative-constraint}} and
{{I-D.martherus-intent-scope}}. A deployment **MUST** use one action-class taxonomy across all three.

## Monotonicity

Authority **MUST** be non-increasing along a chain. For every predicate present at depth *n*, the value
at depth *n+1* **MUST** be equal or narrower.

A verifier **MUST** reject a chain in which any predicate widens, regardless of signature validity. A
correctly signed widening hop is a correctly signed privilege escalation.

## Strict attenuation

A deployment **MAY** require *strict* attenuation: that at least one predicate strictly narrow at each
hop, rather than merely not widening.

Where strict attenuation is required, a hop in which every predicate is unchanged **MUST** be rejected. A
chain of unchanged hops is a credential copy with extra steps.

Strict attenuation is expressed by the governing intent declaration; see
{{I-D.martherus-intent-scope}}. This document defines the predicate semantics that make it checkable.

## Fanout requires enumeration

`fanout` bounds a delegator's direct delegates. It is the predicate that makes the
many-children-at-full-authority pattern refusable rather than merely describable.

**It is not verifiable from a single chain.** Evaluating it requires enumerating the delegator's hops,
which a verifier holding one chain cannot do.

A verifier unable to enumerate a delegator's hops **MUST** report `fanout` as unenforced rather than
treating it as satisfied. Deployments relying on fanout limits **MUST** provide an enumeration mechanism;
{{I-D.martherus-claim-resolution}} defines one suitable form. Absent such a mechanism, `fanout` is
advisory and **MUST** be documented as such.

# Verification

A verifier presented with a chain **MUST**:

1. verify each hop's signature against the delegator's key;
2. verify that each `prior` hash matches the preceding record;
3. verify that `depth` increments by exactly one per hop;
4. verify monotonicity (Section 5.1) for every predicate, and strictness if required (Section 5.2);
5. verify that the action falls within the composed authority; and
6. verify that no hop is expired or revoked (Section 7).

The composed authority is the intersection of every hop's attenuation set.

A verifier **MUST** evaluate the chain to its root. A verifier evaluating only the terminal hop accepts
whatever that hop claims about authority the delegator may never have held.

Where the full chain cannot be obtained, the verifier **MUST** report the chain as `unavailable` (Section
2.1) and **MUST NOT** evaluate the action as authorized on the portion it holds.

# Revocation

**Revocation in delegated capability systems is a known unsolved problem, and this document does not
solve it.** Stated plainly because a specification implying otherwise is worse than one that omits the
subject.

The difficulty is structural: a capability's value is that it verifies without consulting the issuer, and
revocation requires consulting someone. Every known approach trades one against the other.

This document requires only that the trade be explicit. A hop **MAY** carry a `revocation` object naming
a method:

| Method | Property |
|---|---|
| `none` | Not revocable before expiry. Verifiers know this from the record. |
| `endpoint` | An endpoint may be consulted. Availability-dependent. |
| `short_lived` | Revocation by expiry; validity is short and renewal required. |

Deployments **SHOULD** prefer `short_lived` where renewal cost is acceptable, because it is the only
method introducing no consultation dependency on the verification path.

A verifier that cannot reach a revocation endpoint **MUST** treat the hop as `unavailable` and **MUST
NOT** treat it as valid. Treating an unreachable revocation service as implying validity converts a
denial-of-service into a privilege grant.

*(An `epoch` method — revocation by advancing a shared epoch value — was described in an earlier revision
without specification and has been removed. It may return if specified properly.)*

# Relationship to Prior Work

**Capability systems.** Macaroons and successors establish that attenuation belongs in the credential and
is enforceable without issuer consultation. This document adopts that model and supplies what those
systems left application-defined: a registered predicate vocabulary, so attenuation is evaluable across
domains.

**KTP-Identity** {{KTP-IDENTITY}} specifies append-only, dual-signed trajectory chains with sponsorship
bonds, stake transfer, and trust decay along a lineage. It is the closest and most complete prior work on
delegation chains for autonomous agents. This document is complementary by construction: KTP-Identity
governs the chain and the trust that flows along it; this document governs the authority that narrows
along it. {{I-D.martherus-ktp-profile}} defines the binding.

**Token exchange** {{RFC8693}} narrows credentials without producing an evaluable relationship record.
The two compose: a deployment may use token exchange for the credential and hop records for the
relationship.

**Transparency systems.** SCITT {{RFC9943}} establishes signed statements about artifacts with
transparency guarantees. The subject differs — artifacts rather than principals — but the machinery
applies to hop records. See Section 11.

# Security Considerations

**Signature validity does not imply authority.** Section 6's requirement to evaluate to the root is the
central control. A correctly signed hop asserting broad authority proves only that its signer asserted
it.

**Partial chains are not evidence.** An adversary able to withhold intermediate hops can present a
truncated chain whose composed authority appears broader than the true one. Section 6 requires reporting
`unavailable` rather than evaluating a fragment.

**Unreachable revocation is a privilege grant if mishandled.** See Section 7.

**Fanout is unenforceable without enumeration.** See Section 5.3. Deployments that believe they are
enforcing a fanout limit without an enumeration mechanism are not.

**Attenuation does not bound the delegate's other paths.** This document governs authority exercised
through the chain. A delegate holding an independent credential is not constrained by it. Deployments
**MUST** bind enforcement at the resource.

**Non-delegable actions.** Some actions should not be performable through delegation at any depth,
regardless of attenuation. This document defines no such class; it is expressible as a normative
constraint conditioned on chain depth. See {{I-D.martherus-normative-constraint}}.

**Long-lived chains and cryptographic transition.** A chain whose early hops were signed with a later-
deprecated algorithm becomes unverifiable, and unverifiable is not invalid. Section 4.3 requires
migration support; deployments **SHOULD** counter-sign historical records before withdrawal of the
algorithms that signed them, and **MUST** distinguish `unavailable` from `invalid` in records and
decisions (Section 2.1).

# Privacy Considerations

A chain discloses organizational structure: which systems delegate to which, at what depth and scale. A
complete chain set maps an operator's automation topology.

Verifiers should be given the minimum chain required for the decision. Deployments should consider
whether intermediate delegator identities can be replaced with opaque identifiers where the verifier
requires only the composed authority and not the identities.

Where chains are transparency-logged, the disclosure is permanent and public. Deployments should
evaluate that consequence before adopting a transparency substrate.

# Open Items

**The SCITT boundary.** SCITT {{RFC9943}} overlaps Sections 4 and 6. Three positions are possible:
hop records are SCITT statements and this document defines only the payload; hop records are independent
with SCITT optional; or the two address different trust models and should not be coupled. The prior-art
survey notes that SCITT's charter declines to define methods preventing authenticated issuers from making
false claims — **verify that language directly.** If accurate it supports the second position and is
worth citing, since Section 9's central caution is that a valid signature does not imply valid authority.

**Further:**

1. Verify the macaroon caveat-semantics characterization in Section 1 against the original paper.
2. ~~Determine whether `rate` belongs in the registry~~ — **removed 2026-08-05.** It was an operational
   throttle rather than an authority dimension. A deployment needing rate limits applies them as
   deployment configuration; the registry is Specification Required if the case is ever made.
3. Decide whether delegate signature (Section 4.3) should be REQUIRED rather than RECOMMENDED. Requiring
   it forces synchronous delegate participation at mint time; not requiring it lets a delegate plausibly
   deny an attenuation it never accepted.
4. The scope split in Section 1.1 was arrived at by reading KTP-Identity, not by agreement with its
   author. The dependency now lives entirely in {{I-D.martherus-ktp-profile}}, which carries the
   attribution question — but the *framing* of Section 1.1 is still informed by that reading. Confirm it
   is a fair characterization before submission.

# IANA Considerations

This document requests creation of two registries.

**Authority Attenuation Predicates** — initial values `resource`, `action_class`, `data_classification`,
`time`, `depth`, `fanout`. Registration policy: Specification Required.

This is the contribution of the document. {{I-D.martherus-normative-constraint}} Section 6.5 draws the
members of its `scope_reduction` object from this registry, so a registration here widens what a
constraint engine may express as well as what a delegation hop may narrow.

**Authority Attenuation Revocation Methods** — initial values `none`, `endpoint`, `short_lived`.
Registration policy: Specification Required.

## Registration template

Each registration **MUST** supply:

| Field | Description |
|---|---|
| Value | The identifier being registered |
| Description | What it means, in one or two sentences |
| Value type | For predicates: the type of the narrowed value |
| Narrowing relation | For predicates: the relation by which the value narrows |
| Specification | Reference to the document defining it |
| Change controller | The party who may modify or deprecate the registration |
| Contact | Email address for questions |

## Designated expert guidance

The designated expert **SHOULD** approve a predicate registration only where the proposed dimension
admits a well-defined narrowing relation — a predicate that cannot be shown to narrow monotonically
cannot be verified under Section 5.1 and does not belong in this registry. The expert **SHOULD** reject
predicates that describe operational configuration rather than authority, and **SHOULD** reject any
predicate expressing a trust or standing quantity: this registry governs what a delegate may do, not how
much it is trusted.

## Media types

`application/attenuated-hop+json` and `application/attenuated-hop+cbor`, registered per {{RFC6838}} with
this document as the specification and the author as change controller.

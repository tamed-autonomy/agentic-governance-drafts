---
title: "Claim Resolution Profile for Autonomous Agent Governance"
abbrev: "Claim Resolution Profile"
docname: draft-martherus-claim-resolution-00
category: exp
ipr: trust200902
area: Security
workgroup: Independent Submission
keyword: [identity, claims, federation, autonomous agents]
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
  RFC9110:
  RFC7517:
  RFC9728:
  RFC7644:
  OIDF.federation:
    title: "OpenID Federation 1.0"
    target: https://openid.net/specs/openid-federation-1_0.html
    author:
      - org: OpenID Foundation
    date: 2026-02-17
  I-D.martherus-intent-scope:
    title: "Intent Scope Declarations for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
  I-D.martherus-trust-observation:
    title: "Portable Trust Observations for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
  I-D.martherus-authority-attenuation:
    title: "Authority Attenuation Predicates for Delegation Chains"
    author:
      - ins: R. Martherus
    date: 2026
informative:
  RFC7033:
  RFC8414:
---

--- abstract

An agent's identifier is issued by one authority. The facts a relying party needs about that agent —
what it was deployed to do, how it has behaved, what authority it holds — originate with several, and
change on different schedules than the identifier does.

The mechanisms for discovering issuers, retrieving their keys, and querying their claims already exist
and are finished specifications. This document does not redefine them. It profiles them for agent
governance and specifies only what they do not cover: how a role-specific issuer identifier is resolved,
how long verification keys must outlive the claims they signed, and what a relying party does when
issuers disagree.

--- middle

# Introduction

Identity federation solved single-issuer assertion. A relying party learns from one identity provider
who the subject is, and the assertion carries whatever attributes that provider chose to include.

Autonomous agents break the assumption behind that design. The party that issued the agent's identifier
is typically not the party that knows what the agent was deployed to do, is not the party that has
observed its behavior, and is not the party that granted its authority. Those are different authorities,
and their claims change at different rates: an identifier is stable for the agent's lifetime; a
behavioral observation is meaningful for days; a deployment purpose changes when the task changes.

Putting all of it in one token means refreshing all of it at the rate of the fastest-changing member, or
accepting that some of it is stale. Neither is acceptable, and the practical result is that relying
parties consume whatever the token happens to carry and ignore the rest.

## What this document reuses

Nothing in the retrieval path is new, and this document invents none of it.

| Need | Existing specification |
|---|---|
| Multi-party issuer and metadata discovery | OpenID Federation 1.0 {{OIDF.federation}} — Entity Statements, Trust Chains |
| Verification key publication | JSON Web Key Set {{RFC7517}}, located via {{RFC9728}} `jwks_uri` |
| Query, filter, and pagination over a claim collection | SCIM {{RFC7644}} query semantics |
| Transport | HTTP {{RFC9110}} |

{{OIDF.federation}} reached Final on 17 February 2026. Its Entity Statements carry a `jwks` claim and its
Trust Chains provide cryptographically verifiable metadata discovery across multiple parties — which is
the multi-issuer problem this document exists to serve. A deployment already operating a federation
**SHOULD** use it rather than any mechanism described here.

{{RFC9728}} is cited in preference to {{RFC8414}} because the issuers in this profile are not
authorization servers. They are parties that sign their own statements, which is the case
{{RFC9728}} addresses: *"public keys belonging to the protected resource, such as signing key(s) that
the resource server uses to sign resource responses."*

## What this document adds

Three things the reused specifications do not cover:

1. **Issuer roles** (Section 3). Companion specifications name the accountable party differently
   according to what is asserted, and a party trusted in one role is not thereby trusted in another.
2. **Key retention across long-lived claims** (Section 4). Every deployed key-rotation profile assumes
   short-lived credentials. Delegation chains and trust observations are evaluated years after issuance.
3. **Conflict retention** (Section 6). No specification says what to do when two issuers disagree, and
   the common implementation choice — pick one, discard the other — destroys the most useful signal.

## Rescoped

An earlier revision of this document specified its own discovery, retrieval, key discovery, and
enumeration mechanisms. Each duplicated a finished specification. The mechanisms are not the
contribution; the three deltas in Section 1.2 are.

## What this document does not define

It defines no claim types. Claims about purpose are specified in {{I-D.martherus-intent-scope}}, about
behavior in {{I-D.martherus-trust-observation}}, and about delegated authority in
{{I-D.martherus-authority-attenuation}}.

It defines no wire protocol of its own, and a deployment implementing {{OIDF.federation}} and
{{RFC9728}} conformantly, plus Sections 3, 4, and 6 of this document, is complete.

# Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they appear in all capitals.

**Subject:** The agent about which claims are sought.

**Issuer:** The party accountable for a claim.

**Claim Set:** The claims one issuer holds about one subject.

**Resolution:** Obtaining claim sets from multiple issuers for one subject.

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

`unavailable` **MUST NOT** be reported or treated as `absent`. A relying party that treats an unreachable
issuer as silent can be attacked by making it unreachable.

# Issuer Roles

"Issuer" is this document's generic term. Companion specifications name the role according to what the
claim asserts. An implementation **MUST** treat the role-specific identifier as the issuer identifier for
resolution purposes:

| Claim type | Specification | Role | Field |
|---|---|---|---|
| Purpose declaration | {{I-D.martherus-intent-scope}} | Declarant | `declarant` |
| Trust observation | {{I-D.martherus-trust-observation}} | Observer | `observer` |
| Delegation hop | {{I-D.martherus-authority-attenuation}} | Delegator | `delegator` |

A relying party's accepted-issuer set **MUST** be maintained per role, not globally.

The distinction is not cosmetic. A behavioral detection vendor may be entirely trustworthy as an
*observer* and have no standing whatever to *declare* what an agent was deployed to do. Collapsing the
roles into one accepted-issuer list grants every issuer every authority, which is the failure mode that
makes multi-issuer resolution worse than a single trusted issuer rather than better.

A relying party **MUST NOT** derive its accepted-issuer set transitively from another party's without
explicit configuration. Where {{OIDF.federation}} Trust Chains are used, the federation's trust anchors
define which entities may be *discovered*; they do not define which roles a relying party accepts an
entity in.

# Key Retention

Verification keys are published and located per Section 1.1. This section states the one requirement
those specifications do not.

An issuer **MUST** retain a verification key, and continue to publish it, for at least as long as the
maximum validity period of any claim signed under it.

Existing rotation guidance assumes credentials that expire in minutes or hours, so discarding a
superseded key is harmless. That assumption does not hold here. A delegation chain
({{I-D.martherus-authority-attenuation}}) may be evaluated years after its early hops were minted, and a
trust observation's value increases with age. An issuer that discards a superseded key destroys the
verifiability of its own prior statements, and does so silently — the claims remain well-formed and
become permanently `unavailable`.

A relying party **MUST NOT** accept a verification key learned from the same response as the claim it
verifies. A signature verified against a key supplied by the signer proves only self-consistency. Keys
**MUST** be obtained through the mechanisms of Section 1.1, independently of claim retrieval.

Where a key cannot be retrieved, affected claims are `unavailable` — not `invalid`, and not `absent`
(Section 2.1). The distinction determines whether a relying party retries, alerts, or proceeds without
the claim.

# Retrieval Profile

## The relying party asks; the subject does not present

A subject permitted to select which issuers are consulted will select favorably. Resolution **MUST** be
driven by the relying party.

Where a subject presents claims about itself, the relying party **MUST** treat the presented set as
incomplete by default and **SHOULD** obtain claims from issuers directly.

This is the substantive difference from holder-mediated presentation protocols, which are designed for
a subject disclosing its own credentials. That model is correct for a person presenting a qualification
and wrong for an enforcement point evaluating an agent.

## Expiry

A claim published for retrieval by another party **MUST** carry an explicit expiry. Companion
specifications that make expiry optional for locally held artifacts **MUST** treat it as required for
anything published to a resolution endpoint; see {{I-D.martherus-trust-observation}} Section 4.2.

A relying party **MAY** cache a claim until its stated expiry and **MUST NOT** cache beyond it. Beyond
expiry the claim is `expired`, which is distinct from `absent`: a relying party **SHOULD** retain the
knowledge that an expired claim existed.

## Deadlines

Resolution occurs on the decision path, and its latency is a security property: a step slow enough to be
routinely skipped is a control that is not deployed.

A relying party **MUST** apply a deadline per issuer and **MUST** record an issuer that misses it as
`unavailable` rather than as holding no claims.

## Enumeration

Some evaluations require all claims of a type from one issuer rather than a single claim. The `fanout`
attenuation predicate is the motivating case: it bounds a delegator's direct delegates and cannot be
verified from a single chain ({{I-D.martherus-authority-attenuation}} Section 5.3).

Where an issuer supports enumeration, it **SHOULD** use SCIM {{RFC7644}} query semantics — filtering,
pagination, and the list response envelope — rather than defining its own.

An issuer that does not support enumeration **MUST** respond with an explicit indication to that effect,
distinguishable from an empty result. A relying party receiving it **MUST** report any constraint
depending on enumeration as unenforced and **MUST NOT** treat it as satisfied.

Enumeration discloses an issuer's full delegation or observation activity for a subject class. Issuers
**SHOULD** restrict it to relying parties with a demonstrated need and **SHOULD NOT** offer it
unauthenticated.

# Conflict Retention

Two issuers may hold incompatible claims about one subject.

This document defines **no precedence order** among issuers. Precedence is local policy, because the
relative authority of a deployment registry and a behavioral observer differs by deployment and by claim
type.

Implementations **MUST**:

- retain all conflicting claims rather than discarding those not selected;
- record which claim was relied upon, in the decision record; and
- be capable of surfacing that a conflict existed.

Implementations **MUST NOT** silently merge conflicting claims into a single value.

A conflict is frequently more informative than either claim. Two issuers disagreeing about an agent's
delegated authority is a fact about the deployment — a misconfiguration, a stale registry, or a
compromised issuer — and discarding it to produce a clean answer destroys the most useful signal
available.

# Security Considerations

**Discovery is an injection surface.** An attacker able to influence what a discovery mechanism
advertises can introduce an issuer returning favorable claims. Section 3's requirement that discovered
issuers still fall within the relying party's per-role accepted set is the mitigation; deployments
**MUST NOT** accept issuers on the strength of advertisement alone, including advertisement through a
federation Trust Chain.

**Role confusion is privilege escalation.** See Section 3. An implementation maintaining one global
accepted-issuer list grants every accepted issuer the authority of every role.

**Availability affects decisions.** Where a claim cannot be retrieved, the decision is made on less
information. Relying parties **MUST** record that a claim type was `unavailable` and **SHOULD** treat
sustained unavailability as requiring attention rather than as a normal degraded mode.

**Anchor compromise is not total.** A compromised identifier issuer can misstate identity and advertise
malicious issuers, but cannot forge claims held by independent issuers, because claims are independently
signed. That is the principal security benefit of resolution over token-stuffing, and deployments
**SHOULD NOT** undermine it by accepting bundles of claims wrapped in a single issuer's signature in
place of independently signed claims.

**Key retention failure is silent.** See Section 4. Claims signed under a discarded key remain
well-formed and become permanently unverifiable. Deployments **SHOULD** monitor whether issuers they rely
on still publish keys covering the oldest claims they hold.

**Resolution reveals interest.** Querying issuers discloses to each that the relying party is evaluating
the subject, and the requested claim types disclose what the relying party's controls examine.
Deployments handling sensitive subjects **SHOULD** consider whether queries can be batched or padded.

# Privacy Considerations

Resolution assembles a profile that no single issuer holds. That is its purpose and its hazard.

Relying parties **MUST** request only the claim types required for the decision at hand and **MUST NOT**
retain resolved claim sets beyond the decision's audit requirement.

An issuer answering queries from many relying parties learns where a subject operates. Issuers **SHOULD
NOT** retain resolution query logs beyond operational need.

Where the subject acts for a natural person, an assembled claim set may constitute personal data even
where no single claim does. The assembled set, not the individual claims, is the thing deployments
should evaluate against applicable law.

# IANA Considerations

This document requests no new registries.

It profiles existing mechanisms and defines no values requiring registration. The role identifiers in
Section 3 are drawn from the companion specifications that define them.

# Open Items

1. Confirm whether {{OIDF.federation}} Entity Statement metadata can carry a role qualifier (Section 3)
   directly, or whether the per-role accepted-issuer set must be entirely relying-party-side
   configuration. If Federation can express it, Section 3 should profile that rather than describe local
   configuration.
2. Determine whether the Section 4 retention requirement should be expressed as a metadata member an
   issuer publishes — "keys retained for N" — so a relying party can evaluate an issuer's suitability
   before depending on it, rather than discovering the gap when verification fails.
3. WebFinger {{RFC7033}} is listed informatively and not profiled. Decide whether it has a role for
   deployments without a federation, or should be dropped.
4. Verify the SCIM {{RFC7644}} query semantics characterization in Section 5.4 against the specification;
   the current text asserts the shape without citing specific sections.
5. This document is now short. Reconsider whether Sections 3, 4, and 6 are better placed as sections
   within the three companion specifications, eliminating it entirely. The argument for keeping it is
   that all three deltas are cross-cutting and would otherwise be stated three times.

--- back

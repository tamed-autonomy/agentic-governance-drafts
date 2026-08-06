---
title: "Cooperative Enforcement and Decision Composition for Autonomous Agents"
abbrev: "Cooperative Enforcement"
docname: draft-martherus-layer-handoff-00
category: exp
ipr: trust200902
area: Security
workgroup: Independent Submission
keyword: [authorization, policy composition, autonomous agents, enforcement]
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
  I-D.martherus-normative-constraint:
    title: "Normative Constraint Exchange for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
informative:
  I-D.martherus-authority-attenuation:
    title: "Authority Attenuation Predicates for Delegation Chains"
    author:
      - ins: R. Martherus
    date: 2026
  RFC6838:
  W3C.trace-context:
    title: "Trace Context"
    target: https://www.w3.org/TR/trace-context/
    author:
      - org: World Wide Web Consortium
    date: 2021-11
  RFC9943:
  I-D.martherus-trust-observation:
    title: "Portable Trust Observations for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
---

# Cooperative Enforcement and Decision Composition for Autonomous Agents

**Status:** Pre-submission working copy. Not filed with the IETF Datatracker.

⚠️ **This document is not standalone.** It takes a normative dependency on
{{I-D.martherus-normative-constraint}} for the decision vocabulary (Section 3), the decision registry
(Section 10), and the crypto-agility requirements (Section 4). The `stand_alone` flag in the frontmatter
governs kramdown reference handling, not editorial independence.

---

## Abstract

Authorization for autonomous agents is increasingly evaluated by more than one specialized component:
identity, behavioral analysis, declared-purpose scope, trust history, and contextual constraint each
reach independent conclusions about the same proposed action. No specification defines how those
conclusions combine, in what order, with what authority, or how the composed outcome is attested.

This document defines a composition protocol for independent policy enforcement points. It specifies the
decision contributions a participant may make, how contributions compose, and the record that attests
the composed outcome. It does not define any participant's internal logic.

---

## 1. Introduction

The OpenID Foundation's AuthZEN Authorization API 1.0 (Final) defines the interface between one policy
enforcement point and one policy decision point. Its Access Evaluations API supports batched evaluation
with `execute_all`, `deny_on_first_deny`, and `permit_on_first_permit` semantics. It explicitly does not
define chained decision points, policy composition across enforcers, or hierarchical decision
aggregation. Each decision point is independent.

That is the correct scope for a single-PDP interface, and it leaves a gap. An organization deploying an
identity gateway, a behavioral detection product, an intent-scope evaluator, and a normative constraint
engine has four decision points, four vendors, four answers, and no specified way to combine them beyond
whatever the outermost proxy happens to do.

The default resolution — designate one engine as authoritative and reduce the others to signal
providers — reproduces the monolithic policy decision point that the specialization was meant to avoid,
and makes the composed outcome unauditable: the reasoning of the subordinated engines is discarded before
the decision is recorded.

This document specifies the alternative.

### 1.1 Relationship to single-PDP interfaces

This specification composes *above* AuthZEN, not instead of it. A participant in a composition chain
**MAY** expose an AuthZEN-conformant interface, and a composition coordinator **MAY** invoke participants
through it. Nothing here requires replacing an existing PDP interface.

Section 5.3 states the required relationship to AuthZEN's batching semantics.

### 1.2 What this document does not do

It does not define what any participant evaluates, how, or with what model. Participants compete on
detection quality, policy expressiveness, and performance. This document defines only the contract
between them.

It does not define a central policy engine, and it deliberately does not permit one. See Section 8.

---

## 2. Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they appear in all capitals.

**Participant:** An enforcement or decision component that contributes to a composed decision.

**Coordinator:** The component that solicits contributions and computes the composed decision. The
coordinator has no evaluative authority of its own (Section 8.1).

**Contribution:** A single participant's signed output for one action.

**Composition Record:** The signed attestation of a composed decision and the contributions that produced
it.

**Layer:** A named evaluative concern — `identity`, `behavior`, `intent`, `trust`, `delegation`,
`context`. A participant declares the layer or layers it speaks for.

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

`unavailable` **MUST NOT** be reported or treated as `absent`. Section 6.2 defines this document's
consequence for an unavailable participant.

---

## 3. Contribution Types

A participant contributes one of the following. These extend the decision vocabulary of
{{I-D.martherus-normative-constraint}} Section 6 with two non-decisional contributions.

| Contribution | Effect on composition |
|---|---|
| `deny` | Composed decision is `deny` |
| `step_up` | Composed decision is at least `step_up` |
| `defer` | Composed decision is at least `defer` |
| `narrow_scope` | Composed scope is intersected with the offered scope |
| `allow_with_logging` | Composed decision is at least `allow_with_logging` |
| `allow` | No restriction contributed |
| `annotate` | No effect on the decision; attaches a typed observation for other participants |
| `abstain` | The participant asserts no opinion (Section 3.2) |

### 3.1 Annotation

`annotate` exists because specialization is only useful if participants can inform each other. An intent
evaluator concluding that an action is "narrowly outside declared scope" may not wish to deny it, but a
normative engine evaluating the same action should be able to see that conclusion.

An annotation **MUST** carry a type identifier and **MUST NOT** carry a decision. A participant receiving
an annotation **MAY** ignore it. Annotations **MUST** be included in the composition record so that a
decision influenced by an annotation is auditable.

Annotations are not trust observations. A trust observation is a durable claim about a subject intended
for reuse; an annotation is scoped to one action. See {{I-D.martherus-trust-observation}}.

### 3.2 Abstention and non-participation

`abstain` means the participant evaluated and has no opinion. It is distinct from failing to respond.

A participant that does not respond within the coordinator's deadline **MUST** be recorded as
`unavailable`, and **MUST NOT** be recorded as `abstain` or `allow`. Section 6 specifies how unavailable
participants affect the composed decision.

The distinction is load-bearing: a system that silently treats an unreachable denier as permissive can be
attacked by making it unreachable.

---

## 4. Composition Record

A composition record is a JSON {{RFC8259}} or CBOR {{RFC8949}} object.

| Member | Type | Required | Description |
|---|---|---|---|
| `action_ref` | string | yes | W3C Trace Context `trace-id` of the action (Section 4.1) |
| `coordinator` | string | yes | Identifier of the composing entity |
| `contributions` | array | yes | One entry per solicited participant |
| `composed_decision` | string | yes | Result of Section 6 |
| `composed_scope` | object | no | Present when any `narrow_scope` contributed |
| `degraded` | boolean | yes | True if any participant was `unavailable` |
| `policy` | string | yes | Identifier of the composition policy applied (Section 6.4) |
| `timestamp` | string | yes | RFC 3339 |

Each contribution entry carries:

| Member | Required | Description |
|---|---|---|
| `participant` | yes | Identifier of the contributing participant |
| `layer` | yes | The layer this participant speaks for |
| `contribution` | yes | The contribution value (Section 3) |
| `escalation_authority` | conditional | REQUIRED when `contribution` is `step_up` or `defer` |
| `scope` | conditional | REQUIRED when `contribution` is `narrow_scope`; the permitted scope |
| `reason` | no | Human-readable justification |
| `annotations` | no | Typed annotations (Section 3.1) |
| `signature` | yes | The participant's signature over its own entry |

`escalation_authority` and `scope` carry the same structures as the corresponding members of a normative
constraint — see {{I-D.martherus-normative-constraint}} Sections 6.4 and 6.5. A participant emitting
`step_up` or `defer` without naming an authority suspends an action with no route to resumption; a participant
emitting `narrow_scope` without a scope contributes a restriction the coordinator cannot compute. In both
cases the coordinator **MUST** reject the contribution as malformed and record the participant as having
contributed nothing, rather than inferring a value.

The coordinator **MUST** sign the composition record. Each participant **MUST** sign its own
contribution. A coordinator **MUST NOT** alter a signed contribution; contributions are included
verbatim.

This is why the record is dual-signable at two levels: the coordinator attests *what it composed*, and
each participant independently attests *what it said*. A coordinator that misreports a participant's
contribution is detectable by anyone holding the record.

Records **MUST** be signed with JOSE {{RFC7515}} or COSE {{RFC9052}}, carry explicit algorithm
identifiers, and support algorithm migration. See {{I-D.martherus-normative-constraint}} Section 7.1.

---

### 4.1 Action reference

Records produced by this specification correlate with records produced by companion specifications for
the same action. Correlation uses the `trace-id` of W3C Trace Context {{W3C.trace-context}}.

A record **MUST** carry an `action_ref` member whose value is the 16-byte `trace-id`, hex-encoded, of the
operation the record concerns. Where the enforcement point received a `traceparent` header, the
`trace-id` **MUST** be taken from it rather than generated.

This document defines no correlation identifier of its own. Trace Context is a W3C Recommendation already
emitted by the telemetry infrastructure these enforcement points run inside, and reusing it means an
auditor can join a constraint evaluation, an intent comparison, and a composition record for one action
without any of the three specifications depending on the others.

## 5. Protocol

### 5.1 Solicitation

The coordinator sends the action description to each participant registered for the action's class. The
coordinator **MUST** send the same action description to every participant. Sending divergent
descriptions to different participants defeats the audit property of the composition record.

### 5.2 Deadlines

The coordinator **MUST** apply a deadline to each participant and **MUST** record any participant that
misses it as `unavailable`.

### 5.3 Relationship to AuthZEN batching

Where a coordinator invokes participants through AuthZEN's Access Evaluations API, the composition
policy of Section 6 governs the outcome, and the AuthZEN batching semantics govern only transport
efficiency.

Specifically: `deny_on_first_deny` **MAY** be used as an optimization, since Section 6 composition is
deny-dominant. `permit_on_first_permit` **MUST NOT** be used, because it terminates evaluation before
participants that would have denied are consulted. Implementations **MUST NOT** treat
`permit_on_first_permit` as a valid composition policy.

---

## 6. Composition

### 6.1 Default policy: most-restrictive-wins

The composed decision is the most restrictive contribution received, ordered:

~~~
deny > step_up > defer > narrow_scope > allow_with_logging > allow
~~~

`annotate` and `abstain` do not participate in the ordering.

Where multiple `narrow_scope` contributions are received, the composed scope is the intersection.

### 6.2 Unavailable participants

The composition policy **MUST** declare, per layer, whether unavailability is `fail_closed` or
`fail_open`.

The default **MUST** be `fail_closed`: an unavailable participant produces `step_up`.

`step_up` rather than `deny` is deliberate. An unavailable participant is an operational fault, not a
policy violation, and treating every dependency outage as a denial makes the composed system less
available than its least available participant. `step_up` routes the decision to a human without
asserting that the action was impermissible. `defer` would be wrong here — a dependency outage is not
something to adjudicate later while the caller walks away.

A deployment **MAY** configure `fail_open` for a specific layer. Where it does, the composition record
**MUST** record `degraded: true` and name the layer. A composed `allow` reached because a participant was
unreachable **MUST NOT** be indistinguishable from one reached with full participation.

### 6.3 No overrides

A participant **MUST NOT** be able to override another participant's more restrictive contribution.

Deployments requiring an override path — a clinical urgency exception to a data-handling constraint, for
example — **MUST** express it as a constraint within the participant that owns the concern, not as a
composition-layer override. See {{I-D.martherus-normative-constraint}} Section 6.3.

This is the single most important rule in this document. A composition layer that permits overrides is a
central policy engine wearing a different name, and it reintroduces exactly the property that made
specialization necessary.

### 6.4 Alternative policies

A composition policy other than Section 6.1 **MAY** be defined and **MUST** be identified in the `policy`
member of the composition record. Any alternative policy **MUST** preserve Section 6.3.

---

## 7. Relationship to Prior Work

The argument that authorization should be decomposed into cooperating components is not new. Policy
frameworks of the 2000s separated decision, enforcement, information, and administration points, and that
decomposition survives in current systems.

What those frameworks decomposed was one authority into functional roles. What this document composes is
several *independent authorities* — typically several vendors — with no common policy language and no
shared administrative point. That is the structural difference, and it is a consequence of the market
shape rather than a theoretical advance.

Trust-management systems addressed distributed authority through delegation of authorization from a
common root. This document does not assume a common root, because in the deployment case there is none:
the identity vendor and the behavioral detection vendor do not derive authority from each other.

---

## 8. Security Considerations

**The coordinator is not a decision maker, and must not become one.** A coordinator with evaluative
authority is a single point of policy compromise and reintroduces the monolithic PDP. Section 6.3 forbids
overrides for this reason. Deployments **SHOULD** verify composition records independently of the
coordinator that produced them; the per-contribution signatures make this possible.

**Availability is an attack surface on the decision.** Where a layer is configured `fail_open`, making
that participant unreachable converts a would-be denial into an allow. Deployments **SHOULD** treat
`fail_open` configuration as a privileged change and **SHOULD** alert on sustained unavailability of any
participant.

**Annotation is an influence channel.** A compromised participant that cannot deny can still emit
annotations intended to influence other participants. Composition is single-round (Section 5), so an
annotation cannot be used to reopen a contribution already made — but where a deployment feeds
annotations forward into a subsequent evaluation, that bound is lost. Participants **SHOULD** weight
annotations by the annotating participant's authority for the layer it claims, and **MUST NOT** treat an
annotation as authoritative for a layer the annotator does not speak for.

**Divergent solicitation defeats auditing.** A coordinator sending different action descriptions to
different participants can manufacture a composed allow from participants that each evaluated something
other than the real action. Section 5.1 requires identical descriptions; deployments **SHOULD** include a
hash of the action description in each contribution so divergence is detectable after the fact.

**Composition does not bound a participant's own bypass.** This specification governs decisions reached
through the coordinator. An agent with a path to the resource that does not traverse the composition
chain is not governed by it. Deployments **MUST** bind enforcement at the resource rather than relying
solely on a chain the requesting party can decline to enter.

**Enumeration.** A participant learning the full contribution set learns the deployment's control
topology. Coordinators **SHOULD** return to each participant only its own contribution and the composed
outcome, and **SHOULD** restrict full composition records to audit consumers.

---

## 9. Privacy Considerations

A composition record aggregates the conclusions of several evaluators about one action, and is therefore
more revealing than any single contribution. Records **SHOULD** be retained by the relying party rather
than distributed to participants, and participants **SHOULD NOT** receive contributions from layers
outside their concern.

---

## 10. IANA Considerations

This document requests creation of one registry.

**Cooperative Enforcement Layers** — initial values `identity`, `behavior`, `intent`, `trust`,
`delegation`, `context`. Registration policy: Specification Required.

**No registry is created for contribution values.** The decisional contributions are the Normative
Constraint Decisions registry of {{I-D.martherus-normative-constraint}}, used unchanged; registering them
again would let the two diverge, and a decision value meaning one thing to a constraint engine and
another to a coordinator is the failure this document exists to prevent. The two non-decisional
contributions, `annotate` and `abstain`, are closed by construction — a participant either says something
without deciding, or says nothing.

### Registration template

Each registration **MUST** supply:

| Field | Description |
|---|---|
| Value | The identifier being registered |
| Description | What it means, in one or two sentences |
| Specification | Reference to the document defining it |
| Change controller | The party who may modify or deprecate the registration |
| Contact | Email address for questions |

### Designated expert guidance

The designated expert **SHOULD** approve a registration when the value names a genuinely distinct concept
whose meaning is unambiguous from the supplied description, and **SHOULD** reject one that is a synonym
of an existing value, a deployment-local policy knob, or a value whose semantics depend on a single
vendor's implementation. Where a proposed value overlaps an existing one, the expert **SHOULD** ask
whether extending the existing description would serve as well.

### Media types

`application/composition-record+json` and `application/composition-record+cbor`, registered per
{{RFC6838}} with this document as the specification and the author as change controller.

---

## 11. Open Items

1. ~~Verify the AuthZEN Access Evaluations API batching semantics~~ — **verified 2026-08-05** against
   Authorization API 1.0 Final (11 January 2026), Section 7.1.2.1. `execute_all` (default) processes all
   requests independently; `deny_on_first_deny` short-circuits on any denial or error, behaving as
   logical AND; `permit_on_first_permit` short-circuits on any permit, behaving as logical OR. Sections 1
   and 5.4 are accurate as written, and the prohibition on `permit_on_first_permit` as a composition
   policy is correct — it is an OR over participants, which is the inverse of this document's model.
2. Determine the relationship to AuthZEN's Authorization API Resource Profile (AARP), which the prior-art
   survey identifies as colliding with this primitive. AARP may already cover part of Section 5.
3. Decide whether the coordinator role should be specified as a distinct entity or as a role any
   participant may assume. The current text assumes a distinct entity.
4. Determine whether composition records should be transparency-logged, and if so whether SCITT
   {{RFC9943}} is the right substrate. Note that {{I-D.martherus-authority-attenuation}} faces the same
   question for hop records; the two should be answered together or the set will carry two different
   transparency stories.
5. ~~Two-phase composition may be unnecessary complexity~~ — **removed 2026-08-05.** Composition is
   single-round. Two-phase evaluation required ordering rules, a no-loosening constraint, and a
   termination guarantee, for a benefit no deployment had asked for. If participants later prove they
   need to see each other's annotations before contributing, it returns as an extension with the
   single-round case unchanged.

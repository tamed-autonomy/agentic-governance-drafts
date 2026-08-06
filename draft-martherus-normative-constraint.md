---
title: "Normative Constraint Exchange for Autonomous Agents"
abbrev: "Normative Constraint Exchange"
docname: draft-martherus-normative-constraint-00
category: exp
ipr: trust200902
area: Security
workgroup: Independent Submission
keyword: [authorization, obligations, autonomous agents, policy]
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
  OIDF.authzen:
    title: "Authorization API 1.0"
    target: https://openid.net/specs/authorization-api-1_0-final.html
    author:
      - org: OpenID Foundation
    date: 2026-01-11
  CSA.aarm:
    title: "Autonomous Action Runtime Management (AARM) v1.0"
    target: https://aarm.dev/spec
    author:
      - org: Cloud Security Alliance
    date: 2026-02
  AgenticRei:
    title: "Deontic Policies for Runtime Governance of Agentic AI Systems"
    target: https://arxiv.org/abs/2606.19464
    author:
      - ins: A. Joshi
      - ins: T. Finin
      - ins: K.P. Joshi
      - ins: L. Kagal
    seriesinfo:
      arXiv: 2606.19464
    date: 2026-06
  GrossiAldewereldDignum:
    title: "Ubi Lex, Ibi Poena: Designing Norm Enforcement in E-Institutions"
    author:
      - ins: D. Grossi
      - ins: H. Aldewereld
      - ins: F. Dignum
    date: 2006
  Chisholm1963:
    title: "Contrary-to-Duty Imperatives and Deontic Logic"
    author:
      - ins: R. Chisholm
    seriesinfo:
      Analysis: "24"
    date: 1963
  P3P:
    title: "The Platform for Privacy Preferences 1.0 (P3P1.0) Specification"
    target: https://www.w3.org/TR/P3P/
    author:
      - ins: L. Cranor
      - org: World Wide Web Consortium
    date: 2002
  Edelman2009:
    title: "Adverse Selection in Online 'Trust' Certifications"
    author:
      - ins: B. Edelman
    date: 2009
  SHADEArena:
    title: "SHADE-Arena: Evaluating Sabotage and Monitoring in LLM Agents"
    target: https://arxiv.org/abs/2506.15740
    author:
      - ins: J. Kutasov
    seriesinfo:
      arXiv: 2506.15740
    date: 2025
  GoalDrift:
    title: "Evaluating Goal Drift in Language Model Agents"
    target: https://arxiv.org/abs/2505.02709
    author:
      - ins: R. Arike
      - ins: E. Donoway
      - ins: H. Bartsch
      - ins: M. Hobbhahn
    seriesinfo:
      AIES: "2025"
    date: 2025
  METR2025:
    title: "Recent Frontier Models Are Reward Hacking"
    target: https://metr.org/blog/2025-06-05-recent-reward-hacking/
    author:
      - org: METR
    date: 2025-06
  RFC6838:
  OIDF.ssf:
    title: "OpenID Shared Signals Framework Specification 1.0"
    target: https://openid.net/specs/openid-sharedsignals-framework-1_0.html
    author:
      - org: OpenID Foundation
    date: 2025-08-29
  RFC8935:
  RFC8936:
  W3C.trace-context:
    title: "Trace Context"
    target: https://www.w3.org/TR/trace-context/
    author:
      - org: World Wide Web Consortium
    date: 2021-11
  RFC9396:
  RFC8693:
  RFC9943:
  I-D.martherus-layer-handoff:
    title: "Cooperative Enforcement and Decision Composition for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
  I-D.martherus-intent-scope:
    title: "Intent Scope Declarations for Autonomous Agents"
    author:
      - ins: R. Martherus
    date: 2026
---

--- abstract

Authorization systems for autonomous agents answer whether an actor is permitted to perform an action.
They do not carry the obligations and prohibitions that a relying party requires to be evaluated
alongside that permission — trading blackout windows, litigation holds, employment status, clinical
urgency, and comparable contextual constraints.

This document defines an interchange format for such constraints, an evaluation lifecycle covering the
periods before, during, and after an action, and the decision vocabulary a constraint emits. It does not
define a reasoner, a policy authoring language, or a normative philosophy. It defines what crosses the
wire between systems that already have their own.

Composition of this engine's decisions with those of other, independent enforcement points is a separate
problem and is not specified here.

--- middle

# Introduction

The OpenID Foundation's Authorization API 1.0 (AuthZEN) {{OIDF.authzen}}, Final as of 11 January 2026,
permits an
authorization decision response to carry a context field conveying — in Section 5.5.1, "Decision
Context" — *"Advices" and/or "Obligations" tied to the access decision.*

It defines no schema for them, no vocabulary, no evaluation lifecycle, and no discharge confirmation. The
slot exists; the contents are unspecified.

Cloud Security Alliance's Autonomous Action Runtime Management (AARM) v1.0 {{CSA.aarm}} requires in R4
that a policy
engine "MUST be capable of producing exactly one of five decisions: ALLOW, DENY, MODIFY, STEP_UP, or
DEFER," and in R2/R3 that stated agent intent be a mandatory policy input. AARM specifies what a runtime
must do. It does not specify any artifact that crosses a trust boundary.

This document supplies the missing artifact. It is positioned as filling a declared placeholder in
AuthZEN and as providing the interchange format that AARM's requirements presuppose — not as an
alternative to either.

## What this document does not do

This specification does not define ethics, values, or alignment. It defines the carriage of constraints
whose content is determined entirely by the deploying organization — its regulator, its counsel, its
clinical governance board, its employment policy. The specification is indifferent to what those
constraints say.

It does not define a policy engine. Reasoners for deontic policy exist and are actively developed
(Section 3). This document specifies the layer beneath them.

It does not attempt to verify agent intent. Intent verification against observed behavior is addressed
in {{I-D.martherus-intent-scope}} and is subject to negative results that make soundness against an
adversary unattainable.

It does not extend OAuth. Rich Authorization Requests {{RFC9396}} and Token Exchange {{RFC8693}} improve
the precision of what is authorized; this document concerns what is *obliged or forbidden* alongside that
authorization, and composes with either.

## Why a relying party would deploy this

A standard that benefits only the party bearing its cost does not deploy. The Do Not Track effort closed
citing "not sufficient deployment ... nor indications of planned support."

The beneficiary here is the relying party, and the benefit is specific: an organization operating agents
across more than one vendor's enforcement point currently reimplements its blackout windows, holds, and
status rules once per product, with no assurance the implementations agree. A constraint expressed once
and evaluated identically at every enforcement point is the deliverable. The vendor's incentive follows
from the buyer's: a product that cannot consume the buyer's existing constraints is a product that must
be configured from scratch.

# Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they appear in all capitals.

**Normative Constraint (or Constraint):** A signed, addressable object expressing an obligation or
prohibition that applies to a class of actions under stated conditions.

**Constraint Issuer:** The entity that signs a constraint and is accountable for its correctness.

**Policy Enforcement Point (PEP):** A component that evaluates constraints against a proposed or
in-flight action and applies the resulting decision.

**Context Signal:** An externally sourced fact referenced by a constraint condition — employment status,
market calendar state, matter hold status, patient acuity.

**Signal Source:** The system of record for a class of context signals.

**Degraded Context:** The state in which one or more signal sources required by an applicable constraint
are unavailable.

**Enforcement mode:** Whether a matched constraint blocks the action (*regimented*), permits the action
and records a sanctionable violation (*enforced*), or permits and records without sanction (*recorded*).
These are distinct mechanisms with distinct latency and observability requirements and MUST NOT be
conflated.

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

`unavailable` **MUST NOT** be reported or treated as `absent`. Section 8 defines this document's
consequence for an unavailable signal source.

## Action description

Constraints are evaluated against an action description. This document does not define a transport for
it, but requires that the following be resolvable from the evaluation context, since conditions
(Section 4.2) reference them by dot-path:

| Field | Description |
|---|---|
| `action.class` | The action class, drawn from the deployment's action-class taxonomy |
| `action.resource` | The resource acted upon |
| `action.subject` | The acting principal |
| `action.data_classification` | Classification of data involved, where applicable |

A deployment **MUST** use one action-class taxonomy across every specification in this set that
references `action_class`.

# Relationship to Prior Work

This document introduces no new idea. The argument that permission alone is insufficient, and that
obligations belong in a layer above access control, is decades old. What has changed is the deployment
substrate.

## Directly overlapping work

**AgenticRei** {{AgenticRei}} (Joshi, Finin, Joshi and Kagal, IEEE Symposium on Agentic Services,
June 2026) is an
OWL-based deontic policy language built on Rei, providing obligations, dispensations, policy conflict
resolution, and reasoning with the logic engine deliberately outside the model. Its critique of
incumbent engines — that XACML, Rego and Cedar address only the permit/prohibit subset — is the same
critique that motivates this document.

AgenticRei is a policy language and a reasoner. It defines no wire format, no signed artifact, no
issuer accountability model, and no cross-domain federation. **This document specifies the carriage
layer beneath such a reasoner and is intended to be satisfiable by one.** Implementers seeking
expressive deontic reasoning should use AgenticRei or an equivalent; this specification governs what
crosses the boundary between the reasoner's domain and another party's.

The encoding choices here (Section 7) are deliberately independent of AgenticRei's. Nothing in this
document requires OWL, RDF, or a description-logic substrate.

**Normative multi-agent systems** research has specified electronic institutions, norm regimentation and
enforcement, and monitoring-bounded norms since the late 1990s. Grossi, Aldewereld and Dignum's
{{GrossiAldewereldDignum}}
distinction between regimentation and enforcement is adopted here directly (Section 2, Section 5.3).

**Policy language lineage.** KAoS, Rei and Ponder were each technically sound and none achieved broad
adoption. XACML achieved the widest deployment of its generation and its own literature identifies
authoring verbosity and semantic complexity as the barrier. The constructs survived the encoding: the
subject/action/resource/context decision model, policy combining, and obligations reappear in Cedar, in
OPA, and in AuthZEN's request and response shapes. This document takes that history as instruction on
expressiveness (Section 6.6), not as a reason to avoid the constructs.

## Why now

Four conditions differ from those under which the prior work was specified.

1. The governed population exists. Autonomous agents now take consequential actions at volume; normative
   multi-agent systems had no comparable deployment target.
2. Enforcement chokepoints exist. Gateways, tool brokers, and model-context intermediaries are real
   interception points with no analogue in 2003.
3. The authoring and verification burden that sank prior policy languages is now substantially
   automatable.
4. Comparing what was declared against what was done is computationally tractable at scale. It was not
   when machine-readable purpose was last standardized.

## The cautionary case

The Platform for Privacy Preferences {{P3P}} standardized machine-readable purpose declarations. Measured
deployments found approximately one in three compact policies invalid, with identical invalid tokens
circulated as a workaround. P3P declarations opened a gate and were never checked against behavior.

The lesson is adopted as a requirement: **a constraint framework that only gates and never observes will
be falsified at scale.** Section 5.4 requires that enforcement outcomes be observable, and Section 8
requires issuer accountability be carried in the artifact rather than assumed operationally.

## Deontic representation

This document does **not** adopt Standard Deontic Logic semantics, and implementers are cautioned against
treating that system as a baseline despite its name.

The governing reason is contrary-to-duty obligation {{Chisholm1963}}: what is owed *after* a violation
cannot be
consistently represented in a logic that inherits classical consequence inside the obligation operator.
Breach followed by remediation is the ordinary case in agent governance, not an edge case.

This specification sidesteps the problem structurally rather than solving it. Post-violation obligations
are not nested deontic operators. They are ordinary constraints whose conditions reference a recorded
violation event (Section 5.5). A remediation duty is a first-class constraint like any other, triggered
by a fact that the previous evaluation produced. Implementations requiring genuine defeasible reasoning
SHOULD use input/output logic or a defeasible deontic semantics in their reasoner; this document does not
constrain that choice and does not depend on it.

# Constraint Object

A constraint is a JSON {{RFC8259}} or CBOR {{RFC8949}} object with the following members.

| Member | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | Stable identifier, unique within issuer scope |
| `issuer` | string | yes | Identifier of the accountable issuing entity |
| `name` | string | yes | Human-readable label |
| `tier` | string | yes | One of `compliance`, `professional_judgment`, `ethical` (Section 4.1) |
| `action_class` | array of string | yes | Action classes to which the constraint applies |
| `conditions` | array of Condition | yes | Predicates; see Section 4.2 |
| `decision` | string | yes | Decision emitted on match (Section 6) |
| `escalation_authority` | array of string | conditional | REQUIRED when `decision` is `step_up` or `defer` (Section 6.4) |
| `scope_reduction` | object | conditional | REQUIRED when `decision` is `narrow_scope` (Section 6.5) |
| `mode` | string | yes | `regimented`, `enforced`, or `recorded` (Section 5.3) |
| `status` | string | yes | `observe` or `enforcing` (Section 4.3) |
| `reevaluation_triggers` | array of string | no | Events causing re-evaluation during an action (Section 5.2) |
| `not_before` / `not_after` | string | no | RFC 3339 validity bounds |
| `source` | object | no | Provenance of the authority (regulation, policy document, matter ID) |

A constraint **MUST** be signed. See Section 7.

## Tiers

Three tiers are defined. The tier expresses the character of the authority behind a constraint, not its
severity.

- **`compliance`** — constraints traceable to an external obligation: statute, regulation, contract, or
  court order. Litigation holds, trading blackout windows, export restrictions.
- **`professional_judgment`** — constraints reflecting an organization's own standards of practice.
  Clinical escalation thresholds, engineering change freezes, dual-control requirements.
- **`ethical`** — constraints reflecting a normative commitment not otherwise compelled. Interaction
  rules for minors, crisis-contact handling, non-delegable acts.

Tiers do not imply ordering of decisions. Decision precedence is defined in Section 6.3 and is
independent of tier.

Implementations **MUST** be able to report which tier produced a given decision. Constraints in different
tiers frequently have different review authorities, and an outcome that cannot be attributed to a tier
cannot be reviewed by the right body.

## Conditions

Each condition is a predicate over context signals and action attributes.

A constraint **MUST** carry at least one condition. **A constraint with an empty `conditions` array MUST
NOT match any action.** This is a fail-safe: an empty predicate set that matched everything would convert
an authoring error into a global enforcement event. Implementations MUST reject such constraints at load
time.

Two condition encodings are defined.

**Structured form (mandatory to implement).** A `field`, `operator`, `value` triple where `field` is a
dot-path into the evaluation context and `operator` is one of `eq`, `neq`, `in`, `not_in`, `gt`, `lt`,
`gte`, `lte`, `contains`, `not_contains`, `is_true`, `is_false`.

~~~
{ "field": "hr.employee.status", "operator": "eq", "value": "notice_period" }
~~~

**Expression form (optional to implement).** A Common Expression Language (CEL) string evaluated against
the same typed context.

~~~
{ "expr": "hr.employee.status == 'notice_period' && data.classification == 'trade_secret'" }
~~~

An implementation that accepts the expression form **MUST** reject any expression that is not
side-effect-free and deterministic.

## Status

`status` governs whether a matched constraint's decision is applied.

- **`observe`** — the constraint is evaluated and the outcome recorded, but the decision is not applied.
- **`enforcing`** — the decision is applied.

`observe` exists so a constraint can be measured against live traffic before it is allowed to affect it.
Implementations **SHOULD** support promotion from `observe` to `enforcing` without reauthoring.

`status` is orthogonal to `mode` (Section 5.3). `status` asks whether this constraint is live; `mode`
asks what kind of control it is when it is.

# Evaluation Lifecycle

Constraints are evaluated at three points. A specification that evaluates only at admission cannot
address a class of failure that is empirically well documented: instruction adherence in language-model
agents degrades over long autonomous operation {{GoalDrift}}, with drift correlating with context length. Admission-
time evaluation alone is insufficient for actions that are not instantaneous.

## Before the action

The PEP evaluates all constraints whose `action_class` match the proposed action. The composed decision
(Section 6.3) is returned to the caller.

## During the action

For actions with duration, a constraint MAY declare `reevaluation_triggers`. When a listed event occurs,
the PEP **MUST** re-evaluate that constraint against current context and apply the composed result to the
remainder of the action.

Defined trigger classes:

- `signal_change` — a referenced context signal changed value
- `elapsed` — a declared interval passed
- `scope_expansion` — the action's resource or data scope grew after admission
- `delegation` — the acting agent delegated to another agent

### Transport for signal change

This document defines no transport by which a PEP learns that a context signal changed. Deployments
**SHOULD** use the OpenID Shared Signals Framework {{OIDF.ssf}}, Final as of 29 August 2025, which
defines both push {{RFC8935}} and poll {{RFC8936}} delivery of asynchronous state change between
cooperating parties. Its existing profiles already carry the class of fact these constraints consult —
employment status, session and device state, risk change.

It is RECOMMENDED rather than REQUIRED because a deployment operating its own signal bus should not be
forced to adopt a second one. But a deployment with *no* propagation mechanism cannot implement
`signal_change` at all, and **MUST NOT** claim support for it.

Re-evaluation producing `deny` **MUST** halt the remainder of the action. It does not retroactively
invalidate work already completed; see Section 5.5.

## Enforcement mode

Each constraint declares how it is controlled.

- **`regimented`** — the action is prevented. Requires that the PEP sit in the action path and that the
  condition be evaluable before the action commits.
- **`enforced`** — the action proceeds; a violation is recorded and is sanctionable. Requires an
  observation channel but not path interception.
- **`recorded`** — the action proceeds; the outcome is recorded without sanction.

**A constraint whose satisfaction cannot be evaluated from signals available at the PEP MUST NOT be
declared `regimented`.** A norm specified over unobservable state is decoration. Implementations **MUST**
reject at load time any `regimented` constraint referencing a signal the PEP cannot resolve.

## After the action

The PEP **MUST** emit an evaluation record for every action against which any constraint matched,
including constraints in `observe` status. The record **MUST** carry an `action_ref` (Section 5.5) and
**MUST** identify the constraints that matched, the decision each produced, the composed decision, the
tier attribution, the approving principal where a `step_up` or `defer` was satisfied, and whether context
was degraded (Section 8).

This requirement is not audit convenience. It is the observation channel that P3P lacked. A constraint
framework whose declarations are never compared against outcomes has no mechanism by which a false or
misconfigured constraint is discovered.

## Action reference

Records produced by this specification correlate with records produced by companion specifications for
the same action. Correlation uses the `trace-id` of W3C Trace Context {{W3C.trace-context}}.

A record **MUST** carry an `action_ref` member whose value is the 16-byte `trace-id`, hex-encoded, of the
operation the record concerns. Where the enforcement point received a `traceparent` header, the
`trace-id` **MUST** be taken from it rather than generated.

This document defines no correlation identifier of its own. Trace Context is a W3C Recommendation already
emitted by the telemetry infrastructure these enforcement points run inside, and reusing it means an
auditor can join a constraint evaluation, an intent comparison, and a composition record for one action
without any of the three specifications depending on the others.

## Post-violation obligations

When a violation is recorded, the evaluation record itself becomes a context signal. Remediation duties
are expressed as ordinary constraints conditioned on that signal.

~~~
{
  "id": "notify-counsel-on-hold-breach",
  "tier": "compliance",
  "action_class": ["*"],
  "conditions": [
    { "field": "violation.constraint_id", "operator": "eq",
      "value": "litigation-hold-matter-4471" }
  ],
  "decision": "step_up",
  "escalation_authority": ["role:legal-counsel"],
  "mode": "regimented",
  "status": "enforcing"
}
~~~

This is the structural avoidance of contrary-to-duty paradox described in Section 3.4. No obligation is
nested inside another; a violation is a fact, and duties conditioned on facts are ordinary constraints.

# Decision Model

## Decision values

| Value | Meaning |
|---|---|
| `deny` | The action MUST NOT proceed |
| `step_up` | The action MUST NOT proceed until a named authority approves it, synchronously |
| `defer` | The action MUST NOT proceed now; it is queued for later processing |
| `narrow_scope` | The action MAY proceed with reduced resource, data, or capability scope |
| `allow_with_logging` | The action MAY proceed; an evaluation record is REQUIRED |
| `allow` | The action MAY proceed |

`step_up` and `defer` both suspend an action, and are distinguished because the caller must do different
things. `step_up` means a decision is pending and the caller waits; `defer` means no decision is pending
and the caller should not. An implementation that collapses them cannot tell a caller whether to hold the
request open or abandon it, which is the difference between a stalled agent and a retried one.

## Mapping to CSA AARM R4

AARM R4 requires exactly five decisions. This document's vocabulary maps onto it without loss:

| This document | AARM R4 |
|---|---|
| `deny` | `DENY` |
| `step_up` | `STEP_UP` |
| `defer` | `DEFER` |
| `narrow_scope` | `MODIFY` |
| `allow_with_logging` | `ALLOW` with obligation |
| `allow` | `ALLOW` |

The mapping is now one-to-one in both directions. Implementations exposing an AARM-conformant interface
**SHOULD** use it.

The distinction between the suspending decisions and `narrow_scope` is preserved because they have
different operational consequences: the first two suspend the action, the third proceeds immediately with
less authority.

## Composition within this engine

When multiple constraints match **at one enforcement point**, the composed decision is the most
restrictive, ordered:

~~~
deny > step_up > defer > narrow_scope > allow_with_logging > allow
~~~

Composition is independent of tier. An `ethical` constraint producing `deny` and a `compliance`
constraint producing `allow` compose to `deny`.

Where multiple `narrow_scope` decisions match, the composed scope is the intersection of the permitted
scopes (Section 6.5).

**Scope note.** This section governs composition *among constraints evaluated by one engine*. It does
**not** govern composition of this engine's output with the outputs of other, independent enforcement
points. That is a distinct problem — the participants do not share a constraint set, a trust root, or an
administrator — and is specified in {{I-D.martherus-layer-handoff}}. An implementation of this document
emits one composed decision; what a coordinator does with it alongside other engines' decisions is out of
scope here.

## Escalation authority

Where `decision` is `step_up` or `defer`, the constraint **MUST** carry `escalation_authority`: a
non-empty array of identifiers permitted to approve the action.

An implementation **MUST NOT** treat a suspending decision as satisfied by approval from a principal
outside that array, and **MUST** record the approving principal in the evaluation record (Section 5.4).

A suspending decision naming no authority is not actionable — it halts an action with no defined
route to resumption — and implementations **MUST** reject such constraints at load time.

## Scope reduction

Where `decision` is `narrow_scope`, the constraint **MUST** carry `scope_reduction`, an object stating
the reduced authority. Members are drawn from the attenuation predicate registry of
{{I-D.martherus-authority-attenuation}} so that reduction here and attenuation across a delegation hop
use one vocabulary:

| Member | Type | Description |
|---|---|---|
| `resource` | array | Resources the action may reach |
| `action_class` | array | Action classes permitted |
| `data_classification` | array | Data classes handleable |

`scope_reduction` states the permitted scope, not the removed scope. Where multiple reductions compose,
the result is the intersection of the permitted sets.

**Only these three predicates are permitted here.** The attenuation registry also defines `time`,
`depth`, and `fanout`, and those **MUST NOT** appear in a `scope_reduction`. They describe properties of a
delegation chain — how long a grant lives, how far it may be passed on, how widely — and a constraint
engine evaluating a single action has no standing to alter them. A deployment needing to bound delegation
does so in the delegation chain, not in a per-action decision.

## On expressiveness

The condition model in Section 4.2 is deliberately restricted. It is not Turing-complete, has no
user-defined functions, and cannot express recursion or quantification over collections.

This is a design decision, not an omission. Every policy language of the prior generation that optimized
for expressiveness failed to achieve adoption, and the one that achieved the widest deployment is
criticized principally for authoring complexity. The languages that shipped at scale — Rego, Cedar, CEL,
and cloud IAM condition expressions — each gave up expressiveness.

Constraints requiring greater expressive power belong in a reasoner (Section 3.1). This document
specifies what crosses the wire, and what crosses the wire should be evaluable identically by
independent implementations without a shared runtime.

# Encoding and Signing

Constraints **MUST** be serialized as JSON {{RFC8259}} or CBOR {{RFC8949}}.

Constraints **MUST** be signed using JOSE {{RFC7515}} for JSON encoding or COSE {{RFC9052}} for CBOR
encoding.

Implementations **MUST NOT** define an XML serialization of this format.

## Cryptographic agility

Every signed constraint **MUST** carry an explicit algorithm identifier. Implementations **MUST NOT**
assume a default algorithm.

Constraints have operational lifetimes measured in years — a litigation hold or an export restriction may
outlive several cryptographic transitions. Implementations **MUST** support algorithm migration without
reissuing constraint identifiers, and **SHOULD** support post-quantum signature algorithms as they are
registered for JOSE and COSE.

A verifier that cannot validate a constraint's signature **MUST** treat the constraint as unavailable and
apply the degraded-context policy of Section 8, rather than treating it as absent.

## What this format is not

This specification defines signed, independently verifiable objects and an append-only record of
evaluations. It does **not** define, require, or presume a distributed ledger, a consensus protocol, a
chain of blocks, or a token. Evaluation records are ordinary signed records held by the enforcing party.
Implementers seeking transparency properties for those records should refer to SCITT {{RFC9943}}.

# Degraded Context

A constraint whose conditions reference an unavailable signal source cannot be evaluated.

Implementations **MUST** implement a degraded-context policy. The default **MUST** be `fail_closed`: an
unevaluable `regimented` constraint produces `deny`.

Implementations **MAY** support a time-boxed operator override permitting continued operation under
degraded context. Where supported, the override **MUST**:

- require an explicit reason string;
- carry a bounded duration, which **MUST NOT** exceed one hour without renewal;
- identify the authorizing principal;
- be recorded in every evaluation record produced while active; and
- be reported in the evaluation response so the caller knows the decision was made under degraded
  context.

An override that is not visible in the response is indistinguishable to the caller from a decision made
on complete information. That is the failure mode this requirement exists to prevent.

# Security Considerations

**Constraint issuance is a privileged operation.** An attacker able to issue constraints can deny
arbitrary actions or, more damagingly, issue an `allow` constraint in `enforcing` status that masks a
`deny` from a legitimate issuer. Composition (Section 6.3) is most-restrictive-wins specifically to make
the latter attack ineffective: an injected `allow` cannot override a `deny`. Deployments **MUST**
restrict which issuers a PEP accepts.

**Issuer accountability is carried in the artifact.** Empirical study of third-party certification
{{Edelman2009}} found
certified entities were more than twice as likely to be untrustworthy as uncertified ones — a signal
whose issuer bears no cost for being wrong does not merely fail, it inverts. The `issuer` member is
mandatory and signatures are mandatory so that an incorrect constraint is attributable.

**Single-implementation dependence is a bypass.** P3P's dependence on one browser implementation and Do
Not Track's dependence on browser cooperation each produced a single point of circumvention.
Deployments **SHOULD** evaluate constraints at more than one enforcement point, and **MUST** bind
enforcement at the resource rather than relying solely on a gate controlled by the requesting party.

**Observation granularity is a security parameter.** Where distinct security-relevant actions produce
indistinguishable telemetry, an agent's behavior is correspondingly less constrained. Deployments
**SHOULD** ensure that actions subject to different constraints emit distinguishable observations.

**Monitoring does not scale as a sole control.** Published evaluation of automated transcript monitoring
{{SHADEArena}}
reports best-case AUC of 0.87 for model-based monitors and 0.65 for human reviewers at approximately 103
minutes per transcript, with the authors observing that thresholds catching most misbehavior imply false
positive rates that make manual review infeasible. This motivates `regimented` mode: for constraints
where post-hoc detection is inadequate, the control must be in the action path.

**Agents may act contrary to stated intent knowingly.** Independent evaluation {{METR2025}} records a
frontier model
answering that its actions did not adhere to user intentions in ten of ten cases where it had
circumvented the task's intent. Constraint evaluation **MUST NOT** rely on agent self-report for any
condition whose value the agent can influence.

**The `observe` status is a disclosure surface.** An agent able to determine that a constraint is in
`observe` rather than `enforcing` status learns which controls are inert. Evaluation responses **SHOULD
NOT** disclose the status of constraints that did not affect the composed decision.

# Privacy Considerations

Constraint conditions routinely reference personal data — employment status, disciplinary state, clinical
context. A constraint object therefore reveals, by its conditions alone, what categories of personal data
a deployment consults, even when no signal values are present.

Constraint distribution **SHOULD** be restricted to enforcement points that require them. Evaluation
records **MUST NOT** include signal values beyond those necessary to explain the decision, and
implementations **SHOULD** support recording a condition as matched without recording the value that
matched it.

# IANA Considerations

This document requests creation of three registries. Enforcement modes are **not** registered: the
regimented / enforced / recorded trichotomy is closed by construction — it enumerates the three things a
control can do — and a registry would invite values that are not enforcement modes.

**Normative Constraint Tiers** — initial values `compliance`, `professional_judgment`, `ethical`.
Registration policy: Specification Required.

**Normative Constraint Decisions** — initial values `deny`, `step_up`, `defer`, `narrow_scope`,
`allow_with_logging`, `allow`. Registration policy: Standards Action.

This registry is shared. {{I-D.martherus-layer-handoff}} uses these values unchanged for cross-enforcer
composition and does not create a second registry. A new decision value affects every consumer of a
composed decision, which is why the policy is Standards Action rather than Specification Required.

**Normative Constraint Re-evaluation Triggers** — initial values `signal_change`, `elapsed`,
`scope_expansion`, `delegation`. Registration policy: Specification Required.

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

## Media types

`application/constraint+json` and `application/constraint+cbor`, registered per {{RFC6838}} with this
document as the specification and the author as change controller.

# Open Items

Items requiring resolution before submission:

1. ~~Verify the AuthZEN "Advices and/or Obligations" clause text~~ — **verified 2026-08-05** against
   Authorization API 1.0 Final (11 January 2026), Section 5.5.1 "Decision Context". Cited in Section 1.
2. Verify CSA AARM R4 wording and confirm the R2/R3 intent-input requirement as characterized.
3. ~~Determine whether `escalate` should split~~ — **resolved 2026-08-05.** Split into `step_up` and
   `defer`; the AARM R4 mapping (Section 6.2) is now one-to-one.
4. Decide whether evaluation records belong in this document or a companion, given the trajectory and
   provenance draft will define a record format.
5. Confirm the relationship to AuthZEN's Access Evaluations API batching semantics
   (`execute_all` / `deny_on_first_deny` / `permit_on_first_permit`) — composition in Section 6.3 must
   not contradict them.
6. Reconcile with the reference implementation, which currently implements the structured condition form
   only and does not implement `reevaluation_triggers`.

--- back

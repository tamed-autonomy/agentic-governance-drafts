# Agentic Governance Internet-Drafts

Working copies of seven Internet-Drafts specifying interchange formats for the governance of autonomous
AI agents — the layer above identity and authorization, not a replacement for either.

**Status: pre-submission.** Nothing here has been filed with the IETF Datatracker. This repository exists
so that a small number of people can argue with the drafts before that happens.

---

## The argument

Agent identity standards are necessary and not sufficient. OAuth and OIDC profiles for agents,
SPIFFE/SPIRE workload identity, SCIM provisioning, CAEP and Shared Signals carrying non-human
principals — that is the right floor, and these drafts do not compete with any of it.

But an agent can pass every check on that floor and still be the wrong actor, for the wrong purpose, at
the wrong moment. The floor answers *who* and *can*. It does not answer *why* and *should*.

What is missing is not a new idea. Normative multi-agent systems research has argued the same thing since
the late 1990s, and AgenticRei made the argument again in June 2026. What is missing is an
**interoperability layer**: signed, portable, cross-domain carriage of constructs that already have
reasoners. Every draft here says so in its Relationship to Prior Work section.

## The architecture

The floor is finished and deployed. It answers **who** an agent is and **can** it perform an operation.
It does not answer **why** the agent is acting or whether it **should** act now — and nothing standard
sits in that gap, so every vendor fills it privately and no two fill it the same way.

![Agentic governance architecture: the question "should this action happen?" sits above a middle band with no shared standard today — why (intent-scope, authority-attenuation), should (normative-constraint), character (trust-observation, claim-resolution), composition (layer-handoff), and result (portable, signed governance artifacts) — which in turn sits on a floor of finished standards, reused not replaced: who (OAuth, OIDC, SPIFFE/SPIRE, SCIM, OpenID Federation), can (AuthZEN 1.0, RAR, Token Exchange), and carriage (JOSE/COSE, JWK, RFC 9728, Trace Context, Shared Signals).](assets/architecture.png)

### Each draft rests on something finished

The middle band is unspecified, not unsupported. Every draft names what it builds on, and where an
existing specification already covers a need it is profiled rather than restated.

| Draft | Rests on |
|---|---|
| normative-constraint | AuthZEN 1.0 §5.5.1 (fills its declared obligations placeholder) · Shared Signals · JOSE/COSE · Trace Context |
| layer-handoff | AuthZEN Access Evaluations API · the decision registry from normative-constraint |
| trust-observation | RATS (RFC 9334) for attestation results · JOSE/COSE |
| intent-scope | OAuth RAR (RFC 9396) · token exchange (RFC 8693) · Trace Context |
| authority-attenuation | token exchange (RFC 8693) · the macaroon lineage · JOSE/COSE |
| claim-resolution | OpenID Federation 1.0 · RFC 9728 · JWK (RFC 7517) · SCIM query semantics |
| ktp-profile | Kinetic Trust Protocol — third-party, see below |

## The drafts

| Draft | Subject | Maturity |
|---|---|---|
| [normative-constraint](draft-martherus-normative-constraint.md) | Obligations and prohibitions as a signed interchange format, with a before/during/after evaluation lifecycle | **Highest.** Fills a declared placeholder in AuthZEN 1.0 §5.5.1 |
| [layer-handoff](draft-martherus-layer-handoff.md) | Composing decisions across independent enforcement points | High. Thinnest prior art of the set |
| [trust-observation](draft-martherus-trust-observation.md) | Signed, typed observations by named observers — deliberately **not** a portable trust score | High |
| [intent-scope](draft-martherus-intent-scope.md) | Purpose declarations, and falsification of them | Medium. Reframed around negative results |
| [authority-attenuation](draft-martherus-authority-attenuation.md) | Predicate vocabulary for how authority narrows across a delegation hop | Medium |
| [claim-resolution](draft-martherus-claim-resolution.md) | Profile of OpenID Federation / RFC 9728 / SCIM for multi-issuer claims | Low. Mostly a profile; may fold |
| [ktp-profile](draft-martherus-ktp-profile.md) | Binding the above to the Kinetic Trust Protocol | ⚠️ **See below** |

### ⚠️ On the KTP profile

`draft-martherus-ktp-profile.md` profiles the [Kinetic Trust Protocol](https://nmcitra.github.io/ktp-rfc/),
which is the work of **Chris Perkins** (New Mexico Cyber Intelligence & Threat Response Alliance),
published under Apache License 2.0. It is not my specification and this document claims no authorship of
it.

That document exists so the other six need *no* KTP dependency at all — the binding is isolated in one
place that can be evaluated on its own terms. It has not yet been discussed with its subject's author.
**It should not be published, filed, or circulated beyond this repository until that conversation
happens.** Its own Section 8 says the same.

## How these are built

- **They name their ancestors.** Every draft carries a Relationship to Prior Work section, because the
  argument is not that this is a new idea. Prior art was surveyed across IETF, OpenID Foundation, NIST,
  CSA, adjacent protocols, and the academic literature; the surveys live in the source repository.
- **They profile rather than restate.** Where a finished specification covers a need, these drafts cite
  it instead of defining their own: W3C Trace Context for record correlation, OpenID Federation and
  RFC 9728 for discovery and keys, SCIM for enumeration semantics, Shared Signals for change
  propagation.
- **They record their own soft ground.** Each draft ends with Open Items — including struck-through
  entries for decisions already made, with the reasoning that settled them.
- **Shared vocabulary is shared, not duplicated.** The decision values, the artifact state vocabulary,
  and the attenuation predicate registry each have exactly one owning document. `make check` enforces
  that every cross-reference resolves.

## What is deliberately *not* claimed

These drafts try hard not to overclaim, because the literature is full of governance proposals that did.

- **Intent is not verified.** Verifying an agent's purpose from its observable actions is not achievable
  against an adversary — there are constructions giving a guaranteed degree of goal ambiguity even when
  the agent's algorithm is fully known to the observer. What is specified is *falsification with
  attributable violation*.
- **Trust does not travel as a reputation score.** No symmetric reputation function over third-party
  reports is sybilproof, so no observation carries one. What does travel is a named observer's
  measurement of what a subject itself earned, on that observer's stated scale — evidence a relying party
  weighs, never a conclusion it inherits. Magnitudes from different observers are not comparable and must
  not be combined.
- **Revocation is not solved.** No delegated-capability system has solved it. These drafts require only
  that a deployment declare which trade-off it took.
- **Nothing here is a ledger.** Signed, hash-linked, append-only records held by the parties that produce
  them. No consensus, no chain of blocks, no token.

## Reviewing

Every draft ends with an **Open Items** section listing what its author already knows is unresolved.
Starting there is the fastest way to find the soft ground.

The most useful review is the kind that says *this is already solved by X* or *this will not deploy
because Y*. Several mechanisms have already been removed from these drafts on exactly that basis, and
they are better for it.

Two adversarial passes for cross-document coherence have already been run, so contradictions between
drafts are less likely than gaps within one. `CONTRIBUTING.md` lists what is already known to be
unresolved.

## Building

Drafts are written in [kramdown-rfc](https://github.com/cabo/kramdown-rfc).

```
make            # build all drafts to .xml and .txt
make clean
```

Requires Ruby 3.2+ (`kramdown-rfc`) and Python (`xml2rfc`):

```
brew install ruby                 # system Ruby 2.6 is too old
gem install kramdown-rfc
python3 -m venv .venv-build && .venv-build/bin/pip install xml2rfc
```

Source layout follows kramdown-rfc conventions: the title comes from the YAML front matter, and
`--- abstract` / `--- middle` / `--- back` delimit the document parts. Section numbers are generated,
not written — headings use `#` for a major section and `##` below it.

## License

The drafts are IETF contributions and carry `ipr: trust200902`, meaning they are subject to the
[IETF Trust Legal Provisions](https://trustee.ietf.org/documents/trust-legal-provisions/). See
[LICENSE](LICENSE).

The Kinetic Trust Protocol, profiled by one of these drafts, is © New Mexico Cyber Intelligence & Threat
Response Alliance and licensed Apache 2.0. See that draft's Section 8.

## Author

Robin Martherus — robin@martherus.com

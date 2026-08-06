# Reviewing and contributing

These drafts are pre-submission. The repository is public so they can be read and argued with before
anything is filed with the IETF, but the work is not being publicised yet and the drafts should be
treated as working copies rather than proposals anyone has signed off.

## The most useful kinds of review

**"This is already solved by X."** The single most valuable finding. Several mechanisms have already been
deleted from these drafts on discovering they duplicated a finished specification — key discovery,
enumeration, record correlation, and change propagation all now profile existing work rather than
reinventing it. If something here restates a solved problem, say so and the text goes.

**"This will not deploy, because Y."** The prior art is full of technically sound governance
specifications that nobody adopted. If an incentive is missing, or the party bearing the cost is not the
party getting the benefit, that is fatal and worth knowing now.

**"You have overclaimed."** These drafts try to be precise about what is *not* achievable — intent
verification, portable trust scores, revocation. If a claim outruns what can actually be delivered, it
undermines the parts that are sound.

**"The prior art says otherwise."** Every draft has a Relationship to Prior Work section written from a
secondary survey. Where a primary source contradicts it, the primary source wins.

## Where to start

Each draft's **Open Items** section lists what its author already knows is unresolved, including several
items marked as needing verification against primary sources. That is the soft ground; start there.

## What is already known

Please don't spend review time on these — they are recorded and being worked:

- IANA sections have registration templates but have not been through a designated-expert review.
- `draft-martherus-claim-resolution` may not warrant being a separate document; its own Open Item 5 asks
  the question.
- `draft-martherus-ktp-profile` profiles Chris Perkins' Kinetic Trust Protocol, shared with attribution
  by mutual agreement. Its Section 4.4 argument rests on a claim about how `E_base` is derived that only
  he can confirm — Open Item 2. That is the single most useful thing anyone could check.
- Several prior-art characterizations derive from a survey rather than a direct read, and are flagged
  individually.

## Mechanics

**Substantive disagreement:** open an issue. Prose is fine; no template.

**Editorial fixes:** pull requests welcome for typos, broken cross-references, malformed tables.

**Before opening a PR that changes normative text,** open an issue first. Normative changes in one draft
frequently break another — the decision vocabulary, the artifact state vocabulary, and the attenuation
predicate registry are all shared across documents.

Run `make check` before submitting; it verifies that every `{{reference}}` resolves to a declared
front-matter entry across all drafts.

## Attribution

Contributions that change normative content will be acknowledged in the draft. Anything that becomes an
IETF submission carries the IPR terms in each draft's front matter (`trust200902`).

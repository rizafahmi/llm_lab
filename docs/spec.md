# LLM Lab Notes — Design & Specification

**Tagline:** Prompt experiments, written down.

---

## 1. Overview

LLM Lab Notes is a lightweight, read‑first web application for collecting and browsing **real prompts** and **qualitative human observations** about how those prompts behave when tested on large language models.

The system intentionally avoids automated evaluation, scoring, or benchmarking. Instead, it functions as a shared notebook that preserves context, intent, and human judgment over time.

---

## 2. Goals

### Primary goals
- Preserve prompts people actually use to test or explore models
- Capture qualitative observations that would otherwise be forgotten
- Provide a calm, readable interface optimized for text
- Make it easy to compare *ideas* and *observations*, not metrics

### Secondary goals
- Encourage high‑signal contributions
- Remain useful even if small and sparsely populated
- Age gracefully as models and versions change

---

## 3. Requirements

### 3.1 Functional requirements

#### Prompt management
- The system must store prompts with:
  - Title
  - Category
  - Prompt text (Markdown)
  - Optional “when to use” guidance
- Prompts must be viewable in a list and on a detail page
- Prompts must be grouped or filterable by category

#### Field notes
- Each prompt may have zero or more field notes
- Notes must support:
  - Free‑form Markdown text
  - Optional list of models tested (plain text)
  - Optional reference URL (repo, blog, gist, etc.)
  - Optional author attribution
- Notes must be displayed in chronological order

#### Read‑only access
- All content must be publicly readable
- No user accounts or authentication are required for viewing

---

### 3.2 Non‑functional requirements

- Fast page load (<200ms server render for typical pages)
- Text‑first, accessible layout
- Minimal client‑side JavaScript
- Clear expectations: no implication of benchmarks or rankings
- Simple deployment and low operational overhead

---

## 4. Explicit Non‑Goals

LLM Lab Notes is **not**:

- A benchmark or evaluation framework
- An automated model testing system
- A leaderboard or comparison engine
- A prompt marketplace
- A social network

These are intentionally excluded to prevent scope creep and false rigor.

---

## 5. Architecture Decisions

### 5.1 Technology stack

| Layer            | Choice                                      | Rationale |
|------------------|---------------------------------------------|-----------|
| Language         | Elixir                                      | Concurrency, clarity, maintainability |
| Web framework    | Phoenix + LiveView                          | Server‑rendered UI, minimal JS |
| Database         | PostgreSQL                                  | Reliable relational storage |
| Styling          | Tailwind CSS                     | Fast, consistent UI |
| Markdown         | Earmark                                     | Simple, predictable rendering |
| Deployment       | Fly.io (recommended)                        | Phoenix‑friendly, simple ops |

---

### 5.2 Architectural principles

- **Server‑rendered by default**: Avoid frontend complexity
- **Read‑heavy design**: Optimize for browsing, not writing
- **Markdown everywhere**: Promotes expressive content
- **Minimal surface area**: Fewer features, fewer bugs

---

## 6. Data Models

### 6.1 Prompt

```text
Prompt
------
id
title (string, required)
category (string, required)
prompt_text (text, markdown, required)
when_to_use (text, markdown, optional)
created_at
updated_at
```

### 6.2 Note

```text
Note
----
id
prompt_id (FK → Prompt)
notes (text, markdown, required)
models_tested (string, optional)
reference_url (string, optional)
author (string, optional)
created_at
updated_at
```

### Relationships
- Prompt `has_many` Notes
- Notes are deleted when a Prompt is deleted

---

## 7. UI Surface

### Pages

#### Prompt Index (`/`)
- Lists all prompts
- Grouped by category
- Each prompt links to its detail page

#### Prompt Detail (`/prompt/:id`)
- Prompt title and category
- Prompt text (Markdown)
- “When to use” section
- Field notes section

### Design tone
- Calm
- Notebook‑like
- No charts, badges, or scores
- Text is the primary visual element

---

## 8. Testing Strategy

### 8.1 Unit tests

- Prompt changeset validation
- Note changeset validation
- Context functions (`list_prompts/0`, `get_prompt!/1`)

### 8.2 LiveView tests

- Prompt index renders prompt titles
- Prompt detail renders prompt text and notes
- Markdown content is rendered correctly

### 8.3 Regression testing focus

Because scope is intentionally small:
- Prioritize preventing accidental feature creep
- Tests should fail if:
  - Notes start implying ranking or scoring
  - Prompt detail loses readability

### 8.4 What we intentionally do *not* test (yet)

- Performance benchmarking
- Load testing
- Security beyond defaults (no auth, no input forms)

---

## 9. Implementation Plan

### Phase 1 — Core (✅ mostly done)
- Data models & migrations
- Prompt index LiveView
- Prompt detail LiveView
- Markdown rendering
- Seed data

### Phase 2 — Polish (2–4 hours)
- Add basic title search
- Improve typography for long prompts
- Add dates to field notes
- Deploy

### Phase 3 — Guardrails (optional)
- CONTRIBUTING.md
- Submission template (even if manual)
- Moderation guidelines (document‑only)

### Phase 4 — Deferred (only if demand exists)
- Authenticated submissions
- Draft notes
- Prompt versioning

---

## 10. Success Criteria

LLM Lab Notes is successful if:
- You personally use it when testing a new model
- You stop forgetting which prompts you like
- At least one other person says:
  *“This is exactly how I think about prompts.”*

Anything beyond that is a bonus.

# LLM Lab Notes — Implementation Plan

A task-based breakdown of the specification into bite-sized milestones.

---

## Phase 1: Core Database & Models

> **Goal:** Establish the data layer and seed with example data.  
> **Estimated time:** 2–3 hours  
> **Acceptance:** Migrations run cleanly, seed data loads, tests pass

### 1.1 Create Prompt migration and schema
- [ ] Generate Ecto migration for `prompts` table with:
  - `title` (string, required)
  - `category` (string, required)
  - `prompt_text` (text, required, for Markdown)
  - `when_to_use` (text, optional, for Markdown)
  - `created_at`, `updated_at` timestamps
- [ ] Create `LlmLab.Prompts.Prompt` schema with validations
- [ ] Add changeset validation: title, category, prompt_text required and non-empty
- [ ] **Test:** Write unit tests for Prompt changeset validation

### 1.2 Create Note migration and schema
- [ ] Generate Ecto migration for `notes` table with:
  - `prompt_id` (FK → prompts, required)
  - `notes` (text, required, for Markdown)
  - `models_tested` (string, optional)
  - `reference_url` (string, optional)
  - `author` (string, optional)
  - `created_at`, `updated_at` timestamps
- [ ] Add foreign key constraint with `on_delete: :delete_all`
- [ ] Create `LlmLab.Notes.Note` schema with validations
- [ ] Add changeset validation: notes required and non-empty
- [ ] Add `has_many` association in Prompt schema
- [ ] **Test:** Write unit tests for Note changeset validation

### 1.3 Seed data
- [ ] Create `priv/repo/seeds.exs` with 3–5 example prompts covering:
  - Different categories (e.g., "Reasoning", "Instruction Following", "Creative Writing")
  - Each prompt has 1–2 sample notes with optional models_tested, reference_url, author
- [ ] Test seed file runs cleanly: `mix ecto.seed`
- [ ] **Verify:** Data is loadable and schema is sound

---

## Phase 2: Read Views (Index & Detail)

> **Goal:** Render prompts and notes in the browser.  
> **Estimated time:** 2–3 hours  
> **Acceptance:** Pages render without errors, content is visible

### 2.1 Prompt index page
- [ ] Create context function `LlmLab.Prompts.list_prompts/0` that returns all prompts sorted by category, then title
- [ ] Create LiveView module `LlmLabWeb.PromptIndexLive` with route `/`
- [ ] Template displays:
  - Prompts grouped by category (use Enum.group_by)
  - Each prompt as a link to its detail page
  - Category headings
  - No formatting requirements yet (plain text is fine)
- [ ] **Test:** LiveView test asserts:
  - Page renders without errors
  - All prompt titles are visible
  - All category headings appear
  - Links have correct `navigate` attribute

### 2.2 Prompt detail page
- [ ] Create context function `LlmLab.Prompts.get_prompt!/1` that returns a single prompt
- [ ] Preload associated notes in the query (eager load)
- [ ] Create LiveView module `LlmLabWeb.PromptDetailLive` with route `/prompts/:id`
- [ ] Template displays:
  - Prompt title and category
  - Prompt text
  - "When to use" section (if present)
  - All associated notes in chronological order (created_at ascending)
  - Back link to index
- [ ] **Test:** LiveView test asserts:
  - Detail page renders for a valid prompt
  - Prompt title, text, and notes all appear
  - Notes are in chronological order

### 2.3 Markdown rendering
- [ ] Add `:earmark` dependency to `mix.exs` (or verify it's already there)
- [ ] Create helper function `LlmLabWeb.MarkdownHelpers.render_markdown/1`
  - Takes a string, returns safe HTML using `Phoenix.HTML.raw/1`
  - Uses Earmark to convert Markdown to HTML
- [ ] Apply helper to:
  - Prompt text in detail view
  - "When to use" in detail view
  - Note content in detail view
- [ ] **Test:** Unit test for helper that:
  - Renders basic Markdown (headers, emphasis, lists)
  - Escapes malicious HTML in input (Earmark does this by default)

---

## Phase 3: UI Polish & Typography

> **Goal:** Make the interface calm and readable.  
> **Estimated time:** 1.5–2 hours  
> **Acceptance:** Pages are visually pleasant, typography is clean

### 3.1 Base layout and typography
- [ ] Ensure the app uses `<Layouts.app>` wrapper in all LiveViews
- [ ] Set up basic Tailwind CSS classes for:
  - Page container (max-width, centered, padding)
  - Headings (h1, h2, h3 sizing and spacing)
  - Body text (line-height, font-size, color)
  - Links (underline, hover state)
- [ ] Test pages visually (no automated test needed; visual review)

### 3.2 Index page design
- [ ] Category headings styled as clear section separators
- [ ] Prompt titles as readable links (consistent hover state)
- [ ] Spacing between categories and prompts
- [ ] Page title ("Prompts" or similar)
- [ ] Optional: Intro text explaining the site
- [ ] **Visual review:** Calm, notebook-like appearance

### 3.3 Detail page design
- [ ] Prompt metadata (title, category) at top
- [ ] Prompt text in readable container
- [ ] "When to use" section clearly separated if present
- [ ] Field notes section with:
  - Note creation date (e.g., "Dec 15, 2024")
  - Author name if present (e.g., "by Jane Doe")
  - Models tested if present (e.g., "Tested on: Claude 3.5, GPT-4o")
  - Reference URL as clickable link if present
  - Note content in readable format
- [ ] Back link styled appropriately
- [ ] **Visual review:** Professional, easy to read long prompts

### 3.4 Responsive design
- [ ] Verify mobile layout works (no horizontal scroll, readable text)
- [ ] Test on tablet view
- [ ] **Device review:** Works on small screens

---

## Phase 4: Search & Filtering

> **Goal:** Help users find prompts by title and category.  
> **Estimated time:** 1–1.5 hours  
> **Acceptance:** Search works, filters narrow results

### 4.1 Basic title search
- [ ] Add context function `LlmLab.Prompts.search_prompts/1` that:
  - Accepts a search string
  - Returns prompts where title or category contains the search term (case-insensitive)
  - Returns empty list if search string is empty
- [ ] Add LiveView event handler `handle_event("search", %{"query" => query}, socket)`
  - Updates socket assign with search results
- [ ] Template includes search input field
  - Debounced input using `phx-change` with 300ms delay
  - Clears on mount or with a reset button
- [ ] **Test:** LiveView test asserts:
  - Search input updates results in real-time
  - Empty search shows all prompts
  - Partial matches work (e.g., "reason" matches "reasoning")
  - Case-insensitive matching

### 4.2 Category filter (optional, defer if time-limited)
- [ ] Add context function `LlmLab.Prompts.list_categories/0` that returns unique categories
- [ ] Add filter dropdown/radio buttons on index page
- [ ] Filter updates results in real-time using LiveView event
- [ ] Combine search + filter: both must match
- [ ] **Test:** Filter + search combination works correctly

---

## Phase 5: Dates & Attribution

> **Goal:** Show when notes were created and who wrote them.  
> **Estimated time:** 30 minutes  
> **Acceptance:** Dates and authors appear on detail page

### 5.1 Display note creation dates
- [ ] In Note template, format `created_at` as human-readable date
  - Use `Calendar.strftime` or Phoenix helper
  - Format: "Dec 15, 2024" or "15 Dec 2024"
- [ ] Display near author name and models tested
- [ ] **Test:** Detail page test asserts dates appear for each note

### 5.2 Improve note metadata display
- [ ] Reorganize note header to show:
  - Creation date (required)
  - Author (if present): "by Jane Doe"
  - Models tested (if present): "Models: Claude 3.5, GPT-4o"
  - Reference link (if present): as a button or icon
- [ ] Use consistent formatting and spacing
- [ ] **Visual review:** Metadata is clear but not overwhelming

---

## Phase 6: Core Testing Suite

> **Goal:** Ensure core functionality is well-tested.  
> **Estimated time:** 1.5–2 hours  
> **Acceptance:** 80%+ test coverage for models and LiveViews

### 6.1 Context tests (unit)
- [ ] Test `LlmLab.Prompts.list_prompts/0` returns all prompts sorted by category
- [ ] Test `LlmLab.Prompts.get_prompt!/1` returns correct prompt or raises
- [ ] Test `LlmLab.Prompts.search_prompts/1` with various inputs
- [ ] Test `LlmLab.Prompts.list_categories/0` returns unique categories

### 6.2 Schema & changeset tests
- [ ] Prompt changeset with valid and invalid data
- [ ] Note changeset with valid and invalid data
- [ ] Foreign key constraint (notes deleted when prompt deleted)

### 6.3 LiveView integration tests
- [ ] Prompt index renders all prompts and navigates correctly
- [ ] Prompt detail renders prompt and notes
- [ ] Search filters prompts in real-time
- [ ] Category filter works (if implemented)
- [ ] Markdown renders without errors
- [ ] Notes appear in chronological order

### 6.4 Helpers & utilities
- [ ] Markdown rendering helper produces safe HTML
- [ ] Date formatting is consistent

---

## Phase 7: Documentation & Guidelines (Optional)

> **Goal:** Set expectations and guidance for contributions.  
> **Estimated time:** 30–45 minutes  
> **Acceptance:** Documentation is clear and useful

### 7.1 CONTRIBUTING.md
- [ ] Brief intro: "This is a notebook for LLM prompts. We welcome submissions."
- [ ] Submission guidelines:
  - Prompt must be a real prompt you've tested
  - Include category
  - Notes are optional but encouraged
  - No benchmarking or ranking language
- [ ] Format template (if accepting submissions manually):
  - Prompt title
  - Category
  - Prompt text (Markdown supported)
  - "When to use" (optional)
  - Note example
- [ ] Link to code of conduct (or brief statement)

### 7.2 Moderation guidelines (internal)
- [ ] Document what makes a good prompt for inclusion
- [ ] Document what to reject (e.g., copyrighted content, misleading claims)
- [ ] Decision tree for borderline cases

---

## Phase 8: Deployment

> **Goal:** Get the site live.  
> **Estimated time:** 1–2 hours  
> **Acceptance:** Site is publicly accessible and stable

### 8.1 Pre-deployment checklist
- [ ] All tests pass: `mix test`
- [ ] No warnings: `mix credo` or formatter check
- [ ] Environment variables configured
  - Database URL
  - Secret key base
  - Any external API keys (if used)
- [ ] Database migrations ready to run on production

### 8.2 Deployment to Fly.io (or preferred platform)
- [ ] Create Fly app configuration (`fly.toml`)
- [ ] Set secrets on Fly: `fly secrets set`
- [ ] Deploy: `fly deploy`
- [ ] Run migrations: `fly releases migrate`
- [ ] Test: Visit live site, verify content loads

### 8.3 Monitoring & validation
- [ ] Check Fly logs for errors: `fly logs`
- [ ] Verify index page loads in <200ms
- [ ] Verify detail page loads in <200ms
- [ ] Verify search works on live site
- [ ] Confirm seed data is loaded or add to production

---

## Phase 9: Deferred (Future, Only if Demand Exists)

> **Goal:** Features to implement only if there's clear user demand.

### 9.1 Authenticated submissions
- [ ] Add user authentication (simple: email-based or OAuth)
- [ ] Create admin dashboard for moderation
- [ ] Enable write API for submissions
- [ ] Email notification on new notes

### 9.2 Draft notes
- [ ] Add `draft` boolean to Note schema
- [ ] Hide draft notes from public view
- [ ] Allow authors to edit their own notes

### 9.3 Prompt versioning
- [ ] Track changes to prompt text over time
- [ ] Allow viewing prompt history
- [ ] Add version comparison view

---

## Work-In-Progress Checklist

Use this to track overall progress:

- [ ] Phase 1: Core database & models
- [ ] Phase 2: Read views (index & detail)
- [ ] Phase 3: UI polish & typography
- [ ] Phase 4: Search & filtering
- [ ] Phase 5: Dates & attribution
- [ ] Phase 6: Core testing suite
- [ ] Phase 7: Documentation (optional)
- [ ] Phase 8: Deployment
- [ ] Phase 9: Deferred features (only if needed)

---

## Notes

- **Dependencies:** Each phase depends on the previous phase's completion. Do not skip ahead.
- **Testing:** Write tests as you implement each task (TDD approach recommended).
- **Time estimates:** These are rough. Adjust based on your experience and complexity.
- **Stretch goals:** If a task finishes early, move to the next phase rather than gold-plating.
- **Questions?** Refer back to `docs/spec.md` for design rationale and non-goals.

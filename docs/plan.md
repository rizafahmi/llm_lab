# LLM Lab Notes — Implementation Plan (Outside-In TDD/BDD)

A feature-driven breakdown using outside-in TDD: write feature tests first, then implement business logic with red-green-refactor cycles.

---

## Workflow

For each feature:

1. **Write feature test** (`test/llm_lab_web/features/`) describing user behavior
2. **Run test (RED)** — fails because implementation doesn't exist
3. **Drop into inner circle** — implement business logic with TDD (unit tests + code)
   - Red: write failing unit test for the business logic needed
   - Green: implement minimal code to pass unit test
   - Refactor: improve the code while keeping tests green
4. **Return to feature test** — verify if:
   - Test now passes (GREEN) → proceed to refactor phase
   - Test still fails → identify next missing piece, repeat step 3
5. **Refactor the entire feature** — clean up feature test, business logic, and UI
6. **Move to next feature**

---

## Feature 1: Browse Prompts by Category

**User story:** As a visitor, I can view the list of all prompts grouped by category.

### Feature Test
- [ ] Create `test/llm_lab_web/features/browse_prompts_test.exs`
- [ ] Write failing feature test:
  - Visit home page (`/`)
  - Assert page contains prompt list grouped by category headings
  - Assert at least two prompts are visible with titles
  - Assert categories are distinct sections
- [ ] **Status:** RED (app doesn't exist yet)

### Phase 1A: Database & Schema (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab/prompts_test.exs` for schema validation
- [ ] Write failing test: `Prompt` changeset requires title, category, prompt_text
- [ ] **Status:** RED
- [ ] Generate migration: `mix ecto.gen.migration create_prompts`
  - Create `prompts` table with: id, title, category, prompt_text, when_to_use, created_at, updated_at
- [ ] Create `LlmLab.Prompts.Prompt` schema with validations
- [ ] **Status:** GREEN (unit test passes)
- [ ] Run unit tests: `mix test test/llm_lab/prompts_test.exs`

### Phase 1B: Context Functions (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab/prompts_test.exs` for context:
  - `list_prompts/0` returns all prompts sorted by category
  - `list_prompts/0` groups data appropriately
- [ ] **Status:** RED
- [ ] Implement `LlmLab.Prompts.list_prompts/0` context function
- [ ] **Status:** GREEN
- [ ] Run unit tests

### Phase 1C: Seed Data (Inner Circle TDD)
- [ ] Create unit test or use seeds to verify data loads
- [ ] Create `priv/repo/seeds.exs` with 3–5 example prompts in different categories
- [ ] **Status:** GREEN after seed loads
- [ ] Run: `mix ecto.reset`

### Phase 1D: LiveView & UI (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab_web/prompts_live_test.exs` for LiveView mounting and rendering:
  - `PromptIndexLive` renders without errors
  - Page content contains prompt titles
  - Page content contains category names
- [ ] **Status:** RED
- [ ] Create `LlmLabWeb.PromptIndexLive` module
  - Mount: fetch and assign prompts
  - Template: display prompts grouped by category
- [ ] **Status:** GREEN
- [ ] Add route `/` to router
- [ ] Run unit tests

### Return to Feature Test
- [ ] Run feature test: `mix test test/llm_lab_web/features/browse_prompts_test.exs`
- [ ] **Status:** GREEN if all steps above are correct
- [ ] If RED: identify missing piece and repeat inner circle

### Refactor Phase 1
- [ ] Clean up feature test: verify assertions are clear and focused
- [ ] Clean up LiveView template: improve typography and styling for readability
- [ ] Clean up schema: ensure validations are clear
- [ ] Run all tests: `mix test` (all tests should pass)
- [ ] **Commit:** "Feature 1: Browse prompts by category"

---

## Feature 2: View Prompt Detail with Field Notes

**User story:** As a visitor, I can click a prompt to see its full text, "when to use" guidance, and associated field notes in chronological order.

### Feature Test
- [ ] Create `test/llm_lab_web/features/view_prompt_detail_test.exs`
- [ ] Write failing feature test:
  - Navigate from home page
  - Click on a prompt title
  - Assert prompt detail page loads with:
    - Prompt title visible
    - Prompt text (Markdown) rendered
    - "When to use" section visible (if present)
    - All associated notes listed
    - Notes in chronological order (oldest first)
  - Assert each note shows creation date
- [ ] **Status:** RED

### Phase 2A: Note Schema & Relationship (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab/notes_test.exs` for schema validation
- [ ] Write failing test: `Note` changeset requires `notes` field and `prompt_id`
- [ ] **Status:** RED
- [ ] Generate migration: `mix ecto.gen.migration create_notes`
  - Create `notes` table with: id, prompt_id (FK), notes, models_tested, reference_url, author, created_at, updated_at
  - Add foreign key constraint with `on_delete: :delete_all`
- [ ] Create `LlmLab.Notes.Note` schema with validations
- [ ] Add `has_many :notes` association to `Prompt` schema
- [ ] **Status:** GREEN
- [ ] Run migrations: `mix ecto.migrate`

### Phase 2B: Context Functions (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab/prompts_test.exs`:
  - `get_prompt!/1` returns a prompt with preloaded notes
  - Notes are ordered by created_at ascending
- [ ] **Status:** RED
- [ ] Implement `LlmLab.Prompts.get_prompt!/1` with `preload(:notes)`
- [ ] **Status:** GREEN
- [ ] Run unit tests

### Phase 2C: Markdown Rendering (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab_web/components/markdown_test.exs`:
  - `render_markdown/1` converts Markdown to HTML
  - Output is safe (marked with `Phoenix.HTML.raw/1`)
  - Headers, emphasis, lists, links all render
- [ ] **Status:** RED
- [ ] Add `:earmark` to `mix.exs` (if not already present)
- [ ] Create helper function `LlmLabWeb.MarkdownHelpers.render_markdown/1`
  - Uses Earmark to convert Markdown to HTML
  - Returns `Phoenix.HTML.raw/1` output
- [ ] **Status:** GREEN
- [ ] Run unit tests

### Phase 2D: LiveView & UI (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab_web/prompts_live_test.exs`:
  - `PromptDetailLive` mounts with a prompt ID
  - Page renders prompt title, text, and notes
  - Notes appear in chronological order
  - Creation date is formatted and visible for each note
- [ ] **Status:** RED
- [ ] Create `LlmLabWeb.PromptDetailLive` module
  - Mount: fetch prompt with notes, assign to socket
  - Template: display prompt, when_to_use, notes with dates
- [ ] **Status:** GREEN
- [ ] Add route `/prompts/:id` to router
- [ ] Update index page template: make prompt titles clickable links
- [ ] Run unit tests

### Phase 2E: Seed Data (Inner Circle TDD)
- [ ] Update `priv/repo/seeds.exs` to include notes for each prompt
  - Add 1–2 notes per prompt with various fields (some with models_tested, reference_url, author; some without)
- [ ] Run: `mix ecto.reset`

### Return to Feature Test
- [ ] Run feature test: `mix test test/llm_lab_web/features/view_prompt_detail_test.exs`
- [ ] **Status:** GREEN if all steps are correct
- [ ] If RED: identify missing piece and repeat inner circle

### Refactor Phase 2
- [ ] Clean up feature test assertions
- [ ] Improve detail page template typography and spacing
- [ ] Improve note metadata display (date, author, models, reference)
- [ ] Run all tests: `mix test` (all tests should pass)
- [ ] **Commit:** "Feature 2: View prompt detail with notes"

---

## Feature 3: Search Prompts by Title

**User story:** As a visitor, I can search for prompts by title or category and see results update in real-time.

### Feature Test
- [ ] Create `test/llm_lab_web/features/search_prompts_test.exs`
- [ ] Write failing feature test:
  - Visit home page
  - Enter text in search input
  - Assert results are filtered to matching prompts
  - Search is case-insensitive
  - Partial matches work (e.g., "reason" matches "reasoning")
  - Clearing search shows all prompts again
- [ ] **Status:** RED

### Phase 3A: Search Context Function (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab/prompts_test.exs`:
  - `search_prompts/1` with empty string returns all prompts
  - `search_prompts/1` filters by title (case-insensitive, partial match)
  - `search_prompts/1` filters by category (case-insensitive, partial match)
  - Results are sorted by category, then title
- [ ] **Status:** RED
- [ ] Implement `LlmLab.Prompts.search_prompts/1` context function
  - Use Ecto.Query with `like` for case-insensitive matching
- [ ] **Status:** GREEN
- [ ] Run unit tests

### Phase 3B: LiveView Event Handler (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab_web/prompts_live_test.exs`:
  - `PromptIndexLive` handles "search" event with query string
  - Search updates the assigned prompts
  - Event with empty query resets to all prompts
- [ ] **Status:** RED
- [ ] Add `handle_event("search", %{"query" => query}, socket)` to `PromptIndexLive`
  - Call `search_prompts/1` and update socket
- [ ] **Status:** GREEN
- [ ] Run unit tests

### Phase 3C: UI (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab_web/prompts_live_test.exs`:
  - Search input is rendered on index page
  - Typing updates results via `phx-change` event
- [ ] **Status:** RED
- [ ] Add search input to index page template
  - Use `<.input>` component with `phx-change="search"` and debounce
- [ ] **Status:** GREEN
- [ ] Run unit tests

### Return to Feature Test
- [ ] Run feature test: `mix test test/llm_lab_web/features/search_prompts_test.exs`
- [ ] **Status:** GREEN
- [ ] If RED: identify missing piece and repeat inner circle

### Refactor Phase 3
- [ ] Clean up feature test assertions
- [ ] Style search input for clarity
- [ ] Optimize search query if needed
- [ ] Run all tests: `mix test`
- [ ] **Commit:** "Feature 3: Search prompts by title"

---

## Feature 4: View Note Metadata (Models, Author, Reference URL)

**User story:** As a visitor, I can see which models were tested, who wrote a note, and where to find more information.

### Feature Test
- [ ] Create `test/llm_lab_web/features/note_metadata_test.exs`
- [ ] Write failing feature test:
  - Navigate to a prompt detail page
  - For each note, assert:
    - Creation date is displayed
    - Author name appears if present
    - Models tested are listed if present
    - Reference URL appears as a clickable link if present
- [ ] **Status:** RED

### Phase 4A: Seed Data Update (Inner Circle TDD)
- [ ] Update seeds to include diverse note metadata
- [ ] Run: `mix ecto.reset`

### Phase 4B: Note Metadata Display (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab_web/prompts_live_test.exs`:
  - Detail page template includes note metadata fields
- [ ] **Status:** RED
- [ ] Update `PromptDetailLive` template to display:
  - Created date (formatted)
  - Author if present
  - Models tested if present
  - Reference URL as a link if present
- [ ] Create helper for date formatting: `LlmLabWeb.DateHelpers.format_date/1`
- [ ] **Status:** GREEN
- [ ] Run unit tests

### Return to Feature Test
- [ ] Run feature test: `mix test test/llm_lab_web/features/note_metadata_test.exs`
- [ ] **Status:** GREEN

### Refactor Phase 4
- [ ] Clean up feature test
- [ ] Improve note metadata layout (readable, not cluttered)
- [ ] Test date formatting across different locales (if needed)
- [ ] Run all tests: `mix test`
- [ ] **Commit:** "Feature 4: Display note metadata"

---

## Feature 5: Markdown Rendering for Prompts and Notes

**User story:** As a visitor, I can read prompts and notes with full Markdown formatting (headers, lists, bold, links, etc.).

### Feature Test
- [ ] Create `test/llm_lab_web/features/markdown_rendering_test.exs`
- [ ] Write failing feature test:
  - Create a prompt with Markdown (headers, emphasis, lists, code blocks)
  - Create a note with Markdown
  - Visit detail page
  - Assert Markdown is rendered as HTML (visual check or HTML inspection)
  - Assert plain text content is preserved
- [ ] **Status:** RED

### Phase 5A: Markdown Rendering in Template (Inner Circle TDD)
- [ ] Create unit test `test/llm_lab_web/components/markdown_test.exs` (if not done in Feature 2):
  - Verify Markdown renders correctly
- [ ] **Status:** (may be GREEN from Feature 2)
- [ ] Update templates to use `render_markdown/1` helper for:
  - Prompt text
  - "When to use" section
  - Note content
- [ ] **Status:** GREEN
- [ ] Run unit tests

### Return to Feature Test
- [ ] Run feature test: `mix test test/llm_lab_web/features/markdown_rendering_test.exs`
- [ ] **Status:** GREEN

### Refactor Phase 5
- [ ] Clean up feature test
- [ ] Test edge cases: special characters, code blocks, links
- [ ] Run all tests: `mix test`
- [ ] **Commit:** "Feature 5: Markdown rendering"

---

## Feature 6: Responsive Design

**User story:** As a visitor on mobile or tablet, I can comfortably read and navigate the site without horizontal scrolling.

### Feature Test
- [ ] Create `test/llm_lab_web/features/responsive_design_test.exs`
- [ ] Write failing feature test (or manual review test):
  - Visit index page at mobile viewport (375px)
  - Assert no horizontal scroll
  - Assert text is readable (font size, line-height)
  - Assert links are tappable (spacing)
  - Visit detail page at tablet viewport (768px)
  - Assert layout is readable
- [ ] **Status:** RED (or depends on CSS)

### Phase 6A: Tailwind CSS & Layout (Inner Circle TDD)
- [ ] Create or update layout component with responsive classes
- [ ] Apply Tailwind responsive utilities to templates:
  - Container: `max-w-4xl mx-auto px-4`
  - Text: `text-lg md:text-xl`
  - Spacing: `py-4 md:py-8`
- [ ] **Status:** GREEN (visual check)
- [ ] Manual testing on actual mobile/tablet devices

### Return to Feature Test
- [ ] Run feature test or manual review: `mix test test/llm_lab_web/features/responsive_design_test.exs`
- [ ] **Status:** GREEN

### Refactor Phase 6
- [ ] Clean up CSS, ensure consistency across pages
- [ ] Test on multiple devices and browsers
- [ ] Run all tests: `mix test`
- [ ] **Commit:** "Feature 6: Responsive design"

---

## Testing Strategy During Development

### Unit Tests (Inner Circle)
- Write in `test/llm_lab/` for business logic (schemas, context functions)
- Write in `test/llm_lab_web/` for UI components and LiveView logic
- Run frequently: `mix test` (all tests)
- Run specific test file: `mix test test/llm_lab/prompts_test.exs`

### Feature Tests (Outer Circle)
- Write in `test/llm_lab_web/features/`
- Describe user-facing behavior, not implementation details
- Use `PhoenixTest` or `Phoenix.LiveViewTest` to interact with pages
- Run after implementing inner business logic: `mix test test/llm_lab_web/features/`

### Test Execution
- Before committing: `mix test` (all tests must pass)
- Before refactoring: `mix test` (baseline)
- After refactoring: `mix test` (verify nothing broke)

---

## Commits & Milestones

Each feature results in one commit:

1. "Feature 1: Browse prompts by category" (database + index page)
2. "Feature 2: View prompt detail with notes" (detail page + notes)
3. "Feature 3: Search prompts by title" (search functionality)
4. "Feature 4: Display note metadata" (dates, authors, models, URLs)
5. "Feature 5: Markdown rendering" (Markdown support)
6. "Feature 6: Responsive design" (mobile/tablet support)

---

## Deployment & Polish (After MVP)

Once all features are complete and tested:

- [ ] Run `mix precommit` to verify quality gates
- [ ] Deploy to staging or production
- [ ] Create CONTRIBUTING.md (optional, if accepting submissions)
- [ ] Add seed data or real content

---

## Deferred Features (Phase 9 from Original Plan)

Only implement if user demand exists:
- Authenticated submissions
- Draft notes
- Prompt versioning

---

## Notes

- **Outside-in TDD ensures:** Features are complete before moving on; changes are incremental; tests provide confidence
- **Red-Green-Refactor inside:** Business logic is clean and well-tested
- **Feature refactoring:** After feature is green, improve the entire feature (tests + code + UI)
- **No skipping:** Each feature depends on the previous; complete them in order
- **Time estimates:** Same as original plan, but adjusted for testing overhead

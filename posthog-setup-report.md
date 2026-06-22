# PostHog post-wizard report

The wizard has completed a deep integration of PostHog analytics into the Seedling plant journaling app. The PostHog iOS SDK was added as a Swift Package Manager dependency, initialized in the app's `SeedlingApp` entry point, and 13 events were instrumented across 8 source files covering the full user journey: garden management, plant journaling (notes, photos, stage updates), and task tracking.

| Event name | Description | File |
|---|---|---|
| `plant_added` | User adds a new plant to their garden. | `Seedling/Core/Home/ViewModels/HomeViewModel.swift` |
| `plant_deleted` | User deletes a plant from their garden. | `Seedling/Core/Home/ViewModels/HomeViewModel.swift` |
| `plant_stage_updated` | User updates the growth stage of a plant. | `Seedling/Core/Edit/ViewModels/StageDraftViewModel.swift` |
| `plant_care_requirements_updated` | User saves updated care requirements for a plant. | `Seedling/Core/Detail/ViewModels/DetailViewModel.swift` |
| `note_created` | User creates a new note for a plant. | `Seedling/Core/Edit/ViewModels/NoteDraftViewModel.swift` |
| `note_edited` | User edits an existing note for a plant. | `Seedling/Core/Edit/ViewModels/NoteDraftViewModel.swift` |
| `note_deleted` | User deletes a note from a plant's journal. | `Seedling/Core/Detail/ViewModels/DetailViewModel.swift` |
| `photo_added` | User adds a new photo to a plant's journal. | `Seedling/Core/Edit/ViewModels/PhotoDraftViewModel.swift` |
| `photo_caption_edited` | User edits the caption of an existing plant photo. | `Seedling/Core/Edit/ViewModels/PhotoDraftViewModel.swift` |
| `photo_deleted` | User deletes a photo from a plant's journal. | `Seedling/Core/Detail/ViewModels/DetailViewModel.swift` |
| `task_created` | User creates a new garden task. | `Seedling/Core/Tasks/ViewModels/TaskDraftViewModel.swift` |
| `task_completed` | User marks a garden task as completed. | `Seedling/Core/Components/Feature/TaskGroupView.swift` |
| `task_deleted` | User deletes a garden task. | `Seedling/Core/Tasks/ViewModels/TasksViewModel.swift` |

## Next steps

We've built some insights and a dashboard for you to keep an eye on user behavior, based on the events we just instrumented:

- [Analytics basics (wizard) — Dashboard](https://us.posthog.com/project/479143/dashboard/1739772)
- [Plants added over time](https://us.posthog.com/project/479143/insights/JevAOhS0)
- [Task completion vs. creation](https://us.posthog.com/project/479143/insights/vPDzYQke)
- [Garden content activity](https://us.posthog.com/project/479143/insights/uxodoDsl)
- [Plant deletions (churn)](https://us.posthog.com/project/479143/insights/w9ggUZie)
- [Total garden actions (last 30 days)](https://us.posthog.com/project/479143/insights/smrunA7o)

## Verify before merging

- [ ] Run a full production build (the wizard only verified the files it touched) and fix any lint or type errors introduced by the generated code.
- [ ] Run the test suite — call sites that were rewritten or instrumented may need updated mocks or fixtures.
- [ ] Add the exact PostHog env var names (`POSTHOG_API_KEY`, `POSTHOG_HOST`) to `.env.example` and any bootstrap scripts so collaborators know what to set.

### Agent skill

We've left an agent skill folder in your project. You can use this context for further agent development when using Claude Code. This will help ensure the model provides the most up-to-date approaches for integrating PostHog.

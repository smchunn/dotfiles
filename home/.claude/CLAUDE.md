# CLAUDE.md

This document defines the rules and expectations for how you should approach coding tasks. Follow these guidelines at all times to ensure correctness, maintainability, and user satisfaction.

## General Principles

### Read Entire Files

Never skim. Always read full files before making changes. Otherwise, you risk duplicating code, misunderstanding the architecture, or breaking existing functionality.

### Commit Early and Often

Break large tasks into logical milestones. After each milestone is completed and confirmed by the user, commit it. Small, frequent commits protect progress and make it easier to recover if later steps go wrong.

### Plan Before Coding

For every new task:

- Understand the current architecture.
- Identify which files need modification.
- Draft a written Plan that includes architectural considerations, edge cases, and a step-by-step approach.
- Get the Plan approved by the user before writing any code.

### Clarity Over Assumptions

If you are unclear about the task, ask the user questions instead of making assumptions.

### Avoid Unnecessary Refactors

Do not perform large refactors unless explicitly instructed. Small opportunistic cleanups (variable renaming, helper extraction) are fine, but major restructuring requires user approval.

## Libraries & Dependencies

### Stay Up to Date

Your internal knowledge may be outdated. Unless the library interface is extremely stable and you are 100% sure, always confirm the latest syntax and usage via Perplexity (preferred) or web search (fallback).

### Never Skip Libraries

Do not abandon or skip a requested library by claiming "it isn't working." It usually means the syntax or usage is wrong. If the user requested a library, use it.

### Handling Deprecation

If a library is truly deprecated or unsupported, provide evidence (e.g., documentation or release notes) and propose alternatives. Never silently switch libraries.

## Coding Practices

### Linting & Validation

Always run linting and format checks after major changes. This catches syntax errors, incorrect usage, and structural issues before the code is shared.

### Organization & Style

- Separate code into files where appropriate.
- Use clear, consistent variable naming.
- Keep functions modular and manageable.
- Avoid oversized files and functions.
- Write concise, meaningful comments.

### Readability First

Code is read more often than it is written. Optimize for readability and maintainability above all.

### No Dummy Implementations

Unless explicitly asked, never provide "placeholder" or "this is how it would look" code. Always implement real, working solutions.

## Problem-Solving Mindset

### Root Cause Over Guesswork

If you encounter repeated issues, investigate the root cause. Do not guess randomly or "throw things at the wall."

### Break Down Large Tasks

If a task feels too big or vague, break it into smaller subtasks. If it's still unclear, push back to the user and ask them to help refine or restructure the request.

## UI & UX Work

### Design Standards

When working on UI/UX, ensure your work is:

- Aesthetically pleasing
- Easy to use
- Consistent with established patterns

### Best Practices

- Follow interaction and micro-interaction standards.
- Prioritize smooth, engaging, user-friendly flows.
- Ensure accessibility (contrast, keyboard navigation, ARIA where relevant).

## Final Principle

Above all, prioritize clarity, correctness, and maintainability. Your goal is to deliver code that future developers (including yourself) can understand and build upon with confidence.

# Diagram Plan

**Last Updated:** 2026-03-02
**Audience:** All contributors
**Purpose:** Defines the planned visual diagrams for this project, their format, target location, and completion status.

---

## Overview

Diagrams use **Mermaid** format (renders natively in GitHub) and are embedded directly in their target architecture documents. All 13 planned diagrams are now complete.

---

## Placeholder Convention

In any document, mark a planned diagram with a comment:

```markdown
<!-- DIAGRAM: Architecture Overview -->
> 📐 *Diagram planned — see [DIAGRAM_PLAN.md](../diagrams/DIAGRAM_PLAN.md)*
```

---

## All Diagrams

### Architecture Diagrams

| Diagram | Target Document | Format | Status |
|---------|----------------|--------|--------|
| System Architecture Overview | `documentation/architecture/SYSTEM_OVERVIEW.md` | Mermaid flowchart TD | ✅ Complete |
| Clean Architecture Layers | `documentation/architecture/BACKEND_ARCHITECTURE.md` | Mermaid flowchart TD | ✅ Complete |
| Frontend Component Tree | `documentation/architecture/FRONTEND_ARCHITECTURE.md` | Mermaid flowchart TD | ✅ Complete |
| CMS ISR Revalidation Flow | `documentation/architecture/CMS_ARCHITECTURE.md` | Mermaid sequence | ✅ Complete |

### Infrastructure Diagram

| Diagram | Target Document | Format | Status |
|---------|----------------|--------|--------|
| Azure Infrastructure | `deployment/CONTAINER_APPS_GUIDE.md` | Mermaid flowchart TD | ✅ Complete |

### Sequence Diagrams

| Diagram | Target Document | Format | Status |
|---------|----------------|--------|--------|
| Authentication Flow | `documentation/architecture/SECURITY_OVERVIEW.md` | Mermaid sequence | ✅ Complete |
| Pattern Vote Flow | `documentation/architecture/BACKEND_ARCHITECTURE.md` | Mermaid sequence | ✅ Complete |

### Entity Relationship Diagram

| Diagram | Target Document | Format | Status |
|---------|----------------|--------|--------|
| Database Schema (ERD) | `documentation/architecture/DATA_MODEL.md` | Mermaid erDiagram | ✅ Complete |

### User Journey Diagrams

| Diagram | Target Document | Format | Status |
|---------|----------------|--------|--------|
| Browse and Vote | `documentation/requirements/FUNCTIONAL_REQUIREMENTS.md` | Mermaid journey | ✅ Complete |
| Create Pattern | `documentation/requirements/FUNCTIONAL_REQUIREMENTS.md` | Mermaid journey | ✅ Complete |

### State Diagrams

| Diagram | Target Document | Format | Status |
|---------|----------------|--------|--------|
| Pattern Lifecycle | `documentation/architecture/BACKEND_ARCHITECTURE.md` | Mermaid stateDiagram-v2 | ✅ Complete |
| Authentication States | `documentation/architecture/SECURITY_OVERVIEW.md` | Mermaid stateDiagram-v2 | ✅ Complete |

### Class Diagram

| Diagram | Target Document | Format | Status |
|---------|----------------|--------|--------|
| Backend Domain Model | `documentation/architecture/BACKEND_ARCHITECTURE.md` | Mermaid classDiagram | ✅ Complete |

---

## Mermaid Conventions

**Color palette (consistent across all diagrams):**

| Color | Usage | Fill / Stroke |
|-------|-------|---------------|
| Blue | Next.js · API layer · Server Components | `#DBEAFE / #2563EB` |
| Green | ASP.NET Core · Core domain layer | `#D1FAE5 / #059669` |
| Amber | Databases · Data/persistence layer | `#FEF3C7 / #D97706` |
| Purple | Strapi CMS · OIDC Providers | `#EDE9FE / #7C3AED` |
| Sky | Azure Platform services | `#E0F2FE / #0284C7` |
| Gray | CI/CD · Infrastructure | `#F3F4F6 / #374151` |
| Teal | Layout components | `#CCFBF1 / #0D9488` |
| Pink | Client Components | `#FCE7F3 / #DB2777` |

**Other conventions:**
- Line breaks in node labels: use `<br/>` not `\n`
- Sequence diagram theme: `%%{init: {'theme': 'base', 'themeVariables': {...}}}%%`
- Subgraph direction: `direction LR` or `direction TB` to override the outer flow
- Placeholder nodes: `stroke-dasharray:5 5` classDef

See [Mermaid documentation](https://mermaid.js.org) for full syntax reference.

---

## Status

| Count | Status |
|-------|--------|
| 0 | Planned |
| 0 | In Progress |
| 13 | Complete |

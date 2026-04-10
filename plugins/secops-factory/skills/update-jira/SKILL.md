---
name: update-jira
description: "Use when updating JIRA security ticket custom fields with enrichment data. Validates data, maps to configured field IDs, and updates via jr CLI."
argument-hint: "<ticket-id>"
---

# Update JIRA Fields

Update JIRA security alert custom fields with enrichment data via `jr` CLI.

## The Iron Law

> **NO JIRA UPDATE WITHOUT REVIEW APPROVAL FIRST**

JIRA updates represent the official record. Updating before review approval means posting unvalidated analysis as authoritative. Check for the review-approval marker before proceeding.

## Announce at Start

Before any other action, say verbatim:

> I am using the update-jira skill to update ticket <ticket-id> with enrichment data.

## Red Flags

| Thought | Reality |
|---|---|
| "The enrichment looks complete, I'll skip review check" | Iron Law. Check for review-approval marker. |
| "I'll update priority first and finish the rest later" | Partial updates create inconsistent state. Update all fields together. |
| "Field update failed, I'll skip it" | Log the failure, continue with other fields, report partial success. |
| "CVSS is 11.0, that seems right" | Validate ranges: CVSS 0.0-10.0, EPSS 0.0-1.0. Reject invalid data. |
| "I don't know the field IDs, I'll guess" | Load field mappings from config. Never guess custom field IDs. |
| "The cloud_id is in the error message, that's fine" | Never expose cloud_id in user-facing output. Security consideration. |

## Process

### Step 1: Check Review Approval

Look for review-approval marker in conversation context or JIRA comments. If not found, HALT:
> Review approval required before JIRA update. Run /review-enrichment first.

### Step 2: Validate Enrichment Data

Validate each field:
- CVE ID: matches `CVE-\d{4}-\d{4,7}`
- CVSS: 0.0-10.0
- EPSS: 0.0-1.0
- KEV: "Listed" or "Not Listed"
- Exploit Status: "None", "PoC", "Public Exploit", "Active Exploitation"
- Priority: P1-P5

Skip invalid fields with warning. Continue with valid fields.

### Step 3: Build and Execute Update

1. Map priority to JIRA priority name (P1->Critical, P2->High, P3->Medium, P4->Low, P5->Trivial)
2. Update fields via `jr` CLI:
   ```bash
   jr issue edit <ticket-id> --priority <priority-name>
   ```
3. Post enrichment summary as a comment:
   ```bash
   jr issue comment <ticket-id> "Enrichment complete. CVSS: X.X, EPSS: X.XX, KEV: Y/N, Priority: PX" --markdown
   ```
4. If status transition needed:
   ```bash
   jr issue move <ticket-id> "Enriched"
   ```
5. Verify update by re-reading the ticket:
   ```bash
   jr issue view <ticket-id>
   ```

### Step 4: Report Results

Report: fields updated, fields skipped, any errors.

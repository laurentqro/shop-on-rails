# Documentation Index

Welcome to the Afida E-Commerce Shop documentation. This directory contains all technical and product documentation for the project.

## Quick Start

New to the project? Start here:

1. **[Main README](../README.md)** - Setup, installation, and getting started
2. **[CLAUDE.md](../CLAUDE.md)** - Architecture overview and development guide for Claude Code
3. **[Developer Guide](developer_guide.md)** - Deep dive into data models, APIs, and common tasks

## Documentation by Purpose

### For Developers

**Getting Started:**
- [README.md](../README.md) - Installation, configuration, running the app
- [Developer Guide](developer_guide.md) - Data models, code examples, common tasks
- [CLAUDE.md](../CLAUDE.md) - Architecture overview and patterns

**Feature-Specific Guides:**
- [Variant Migration Guide](variant_migration_guide.md) - Migrating products to variant system
- [Google Merchant Setup](google_merchant_setup.md) - Setting up Google Shopping feed

### For Product/Business

**Planning & Requirements:**
- [Product Requirements Document (PRD)](prd.md) - Complete feature specifications
- [Development Task List](tasks.md) - Implementation checklist from PRD

### For Operations

**Deployment & Maintenance:**
- [README.md - Deployment Section](../README.md#deployment) - Production deployment checklist
- [README.md - Troubleshooting](../README.md#troubleshooting) - Common issues and solutions

## Documentation Overview

### Main Project Files

| File | Purpose | Audience |
|------|---------|----------|
| [README.md](../README.md) | Main project documentation, setup guide | Everyone |
| [CLAUDE.md](../CLAUDE.md) | Claude Code guide, architecture overview | Developers, Claude |

### docs/ Directory

| File | Purpose | Audience |
|------|---------|----------|
| [developer_guide.md](developer_guide.md) | Technical deep dive, APIs, code examples | Developers |
| [prd.md](prd.md) | Product Requirements Document | Product, Business, Developers |
| [tasks.md](tasks.md) | Development task checklist | Developers, Project Managers |
| [google_merchant_setup.md](google_merchant_setup.md) | Google Shopping setup guide | Developers, Marketing |
| [variant_migration_guide.md](variant_migration_guide.md) | Product variant migration | Developers, Data Migration |

## Quick Reference

### Key Technologies

- **Backend:** Rails 8.0, PostgreSQL
- **Frontend:** Vite, TailwindCSS 4, DaisyUI, Hotwire (Turbo + Stimulus)
- **Payments:** Stripe Checkout
- **Email:** Mailgun
- **Background Jobs:** Solid Queue
- **Storage:** Active Storage (S3 in production)

### Important URLs (Development)

- App: http://localhost:3000
- Admin: http://localhost:3000/admin
- Google Merchant Feed: http://localhost:3000/feeds/google-merchant.xml

### Essential Commands

```bash
bin/setup                   # Initial setup
bin/dev                     # Start development server
rails test                  # Run tests
rubocop                     # Run linter
rails db:migrate            # Run migrations
rails console               # Open Rails console
```

## Documentation Standards

When updating or creating documentation:

1. **Keep it current** - Update docs when code changes
2. **Use examples** - Include code examples where applicable
3. **Target the audience** - Consider who will read it
4. **Link related docs** - Cross-reference related documentation
5. **Use clear headings** - Make docs scannable
6. **Include version info** - Note when features were added/changed

## Finding What You Need

### "I want to..."

**...get the app running locally**
→ [README.md - Quick Start](../README.md#quick-start)

**...understand the architecture**
→ [CLAUDE.md - Architecture Overview](../CLAUDE.md#architecture-overview)

**...learn the data models**
→ [Developer Guide - Data Models](developer_guide.md#data-models)

**...implement a new feature**
→ [Developer Guide - Common Tasks](developer_guide.md#common-tasks)

**...deploy to production**
→ [README.md - Deployment](../README.md#deployment)

**...fix a bug**
→ [README.md - Troubleshooting](../README.md#troubleshooting)

**...understand what to build**
→ [Product Requirements Document](prd.md)

**...migrate products to variants**
→ [Variant Migration Guide](variant_migration_guide.md)

**...set up Google Shopping**
→ [Google Merchant Setup](google_merchant_setup.md)

**...understand the checkout flow**
→ [Developer Guide - Checkout & Orders](developer_guide.md#checkout--orders)

**...work with the shopping cart**
→ [Developer Guide - Shopping Cart Flow](developer_guide.md#shopping-cart-flow)

## Additional Resources

### External Documentation

- [Rails 8 Guides](https://guides.rubyonrails.org/v8.0/)
- [Stripe API Documentation](https://stripe.com/docs/api)
- [Hotwire Handbook](https://hotwired.dev/)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)
- [DaisyUI Components](https://daisyui.com/components/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### Community

- Rails Forum: https://discuss.rubyonrails.org/
- Hotwire Forum: https://discuss.hotwired.dev/
- Stack Overflow: Tag questions with `ruby-on-rails`

## Contributing to Documentation

Found an error or want to improve the docs?

1. Update the relevant file
2. Test any code examples
3. Check links still work
4. Update this index if adding new docs
5. Submit a pull request

## Questions?

If you can't find what you need:

1. Check the [README.md](../README.md) troubleshooting section
2. Review the [Developer Guide](developer_guide.md)
3. Browse the codebase - models have inline documentation
4. Ask the team

---

**Last Updated:** January 2025
**Project Version:** 1.0.0 (Pre-launch)

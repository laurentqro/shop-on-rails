# Test Coverage Improvement Plan

**Current Coverage**: 17.84% (157/880 lines)
**Target**: 80%+ coverage

## Coverage Analysis

### ✅ Already Tested Models (8/11)
- ✅ Cart (12 tests)
- ✅ CartItem (17 tests)
- ✅ Category (19 tests)
- ✅ Order (16 tests)
- ✅ OrderItem (20 tests, 3 skipped)
- ✅ Product (15 tests)
- ✅ ProductVariant (28 tests)
- ✅ User (28 tests)

### 🔴 Untested Areas

#### 1. Missing Model Tests
- **Session model** - Simple model with just belongs_to :user
  - Impact: Low (very simple model)
  - Effort: 15 minutes
  - Estimated coverage gain: +0.5%

#### 2. Mailers (0% tested)
- **OrderMailer** - Order confirmation emails
- **RegistrationMailer** - Email verification
- **PasswordsMailer** - Password reset emails
  - Impact: HIGH (user-facing functionality)
  - Effort: 2-3 hours
  - Estimated coverage gain: +3-5%

#### 3. Controllers (0% tested)
- **Admin controllers** (products, orders, dashboard)
- **Public controllers** (pages, products, cart, checkout)
- **Auth controllers** (sessions, registrations, passwords)
  - Impact: CRITICAL (core application logic)
  - Effort: 8-12 hours
  - Estimated coverage gain: +30-40%

#### 4. Helpers (0% tested)
- **ApplicationHelper** - View helper methods
  - Impact: Low-Medium
  - Effort: 30 minutes
  - Estimated coverage gain: +0.5%

#### 5. Jobs (0% tested)
- **ApplicationJob** - Base job class
  - Impact: Low (base class only)
  - Effort: Minimal
  - Estimated coverage gain: +0.2%

## Prioritized Action Plan

### Phase 1: Quick Wins (2-3 hours) → ~25% coverage
**Goal**: Add Session tests + improve existing model coverage

1. **Add Session model tests** (15 min)
   - Test belongs_to :user association
   - Test any validations

2. **Improve existing model test coverage** (1-2 hours)
   - Add edge case tests for uncovered branches
   - Test error paths and validations
   - Cover any methods we missed

3. **Fix OrderItem skipped tests** (30 min)
   - Add missing `product` association to OrderItem model
   - Enable the 3 skipped tests

### Phase 2: Mailer Tests (2-3 hours) → ~30% coverage
**Goal**: Test all email functionality

1. **OrderMailer tests**
   ```ruby
   test "order_confirmation sends email with order details"
   test "order_confirmation includes order number and items"
   test "order_confirmation email has correct recipient"
   ```

2. **RegistrationMailer tests**
   ```ruby
   test "verification_email includes token link"
   test "verification_email has correct recipient"
   ```

3. **PasswordsMailer tests**
   ```ruby
   test "password_reset includes reset link"
   test "password_reset expires after time limit"
   ```

### Phase 3: Controller Tests (8-12 hours) → ~70% coverage
**Goal**: Integration tests for all controllers

#### A. Authentication Controllers (2 hours)
- SessionsController (login/logout)
- RegistrationsController (signup)
- PasswordsController (reset)
- EmailAddressVerificationsController

#### B. Cart & Checkout Controllers (2-3 hours)
- CartsController
- CartItemsController (add/update/delete)
- CheckoutsController (Stripe integration)

#### C. Public Controllers (2-3 hours)
- PagesController (home, about, contact, etc.)
- ProductsController (index, show)
- CategoriesController
- OrdersController (show, index)

#### D. Admin Controllers (3-4 hours)
- Admin::ProductsController
- Admin::OrdersController
- Admin authentication & authorization

#### E. Other Controllers (1 hour)
- FeedsController (Google Merchant feed)

### Phase 4: System Tests (4-6 hours) → ~85% coverage
**Goal**: End-to-end user flows

1. **Shopping flow**
   - Browse products → Add to cart → Checkout → Order confirmation

2. **Authentication flow**
   - Sign up → Verify email → Login → Logout

3. **Admin flow**
   - Login as admin → Manage products → View orders

### Phase 5: Helper & Job Tests (1 hour) → ~90% coverage

## Specific Recommendations

### Quick Command to Run
```bash
# Phase 1: Session tests
rails test test/models/session_test.rb

# Phase 2: Mailer tests
rails test test/mailers/

# Phase 3: Controller tests
rails test test/controllers/

# Phase 4: System tests
rails test:system
```

### Coverage Targets by Phase
| Phase | Duration | Target Coverage | New Tests |
|-------|----------|----------------|-----------|
| Current | - | 17.84% | 149 tests |
| Phase 1 | 2-3 hrs | ~25% | +20 tests |
| Phase 2 | 2-3 hrs | ~30% | +15 tests |
| Phase 3 | 8-12 hrs | ~70% | +80-100 tests |
| Phase 4 | 4-6 hrs | ~85% | +15-20 tests |
| Phase 5 | 1 hr | ~90% | +5 tests |
| **Total** | **17-25 hrs** | **~90%** | **+135-160 tests** |

## Immediate Next Steps (Recommended)

### Option A: Continue with Models (Low-hanging fruit)
1. Add Session model tests (15 min)
2. Fix OrderItem product association issue (30 min)
3. Run coverage report to see specific uncovered lines

### Option B: Jump to High-Impact (Controller tests)
1. Start with CartsController and CartItemsController tests
2. Add CheckoutsController tests (critical payment flow)
3. Add authentication controller tests

### Option C: Add Mailer Tests (User-facing)
1. OrderMailer tests (most important)
2. RegistrationMailer tests
3. PasswordsMailer tests

## Coverage Analysis Tools

### View detailed coverage report:
```bash
open coverage/index.html
```

### Run tests with verbose coverage:
```bash
COVERAGE=true rails test
```

### Find untested files:
```bash
grep -r "def " app/controllers app/mailers app/jobs | \
  grep -v "test" | wc -l
```

## Notes on Testing Strategy

### What NOT to test:
- Rails framework code
- Third-party gems (Stripe, etc.)
- Generated boilerplate (ApplicationRecord, etc.)

### What to prioritize:
1. **Critical paths**: Checkout, payments, authentication
2. **Business logic**: Cart calculations, order creation
3. **User-facing features**: Emails, product display
4. **Admin features**: Product/order management
5. **Edge cases**: Error handling, validations

### Test Types by Coverage Impact:
1. **Model tests**: ~20% total coverage (mostly done ✅)
2. **Controller tests**: ~40-50% total coverage (biggest gap 🔴)
3. **Mailer tests**: ~5% total coverage (quick win 🟡)
4. **System tests**: ~10-15% total coverage (high value 🟢)
5. **Helper/Job tests**: ~2-3% total coverage (optional 🟡)

## Recommended Starting Point

**I recommend starting with Phase 1 (Quick Wins):**

1. Add Session model tests
2. Fix the 3 skipped OrderItem tests by adding product association
3. Run full test suite and review detailed coverage report
4. Identify specific uncovered lines in existing models

This will get you to ~25% coverage in 2-3 hours, then you can decide whether to continue with mailers or jump straight to controllers.

Would you like me to:
- A) Add Session tests and fix OrderItem issues (Phase 1)
- B) Start with Mailer tests (Phase 2)
- C) Jump to Controller tests (Phase 3)
- D) Generate a detailed coverage report first

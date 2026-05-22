# CharloTech — Seller Registration & Admin Approval System
### Priority 1 + 2: Seller Registration · Admin Approval · Email Login · Dashboard

---

## 📁 Project Structure

```
charlotech/
├── database.sql                  ← Run this first in MySQL
├── frontend/
│   └── public/
│       └── index.html            ← Full SPA (home, register, login, dashboards)
└── backend/
    ├── server.js                 ← Express entry point
    ├── package.json
    ├── .env.example              ← Copy to .env and fill in
    ├── config/
    │   ├── db.js                 ← MySQL connection pool
    │   └── mailer.js             ← Email templates + Nodemailer
    ├── middleware/
    │   └── auth.js               ← JWT auth for sellers + admins
    └── routes/
        ├── sellers.js            ← Register, login, /me endpoint
        └── admin.js              ← List, approve, reject, suspend, stats
```

---

## 🚀 Setup (Step by Step)

### 1. Create the Database
```sql
mysql -u root -p < database.sql
```
This creates the `charlotech` database with all tables and a default admin account.

### 2. Install Dependencies
```bash
cd backend
npm install
```

### 3. Configure Environment
```bash
cp .env.example .env
```
Edit `.env` and fill in:
- `DB_PASSWORD` — your MySQL root password
- `MAIL_USER` / `MAIL_PASS` — Gmail App Password (or any SMTP)
- `JWT_SECRET` / `ADMIN_JWT_SECRET` — change to random strings in production

### 4. Start the Server
```bash
# Development (auto-restart on changes)
npm run dev

# Production
npm start
```

### 5. Open the App
Visit: **http://localhost:3000**

---

## 🔐 Default Admin Login

| Field    | Value                      |
|----------|----------------------------|
| Email    | admin@charlotech.co.za     |
| Password | Admin@Charlo2026           |

> ⚠️ Change this password immediately after first login!
> To update it, run:
> ```sql
> UPDATE admins SET password='<new-bcrypt-hash>' WHERE email='admin@charlotech.co.za';
> ```
> Generate a bcrypt hash: `node -e "const b=require('bcryptjs');b.hash('YourNewPassword',12).then(console.log)"`

---

## 🛠 API Endpoints

### Seller Endpoints
| Method | Endpoint                | Auth     | Description              |
|--------|-------------------------|----------|--------------------------|
| POST   | /api/sellers/register   | None     | Submit seller application |
| POST   | /api/sellers/login      | None     | Seller login → JWT       |
| GET    | /api/sellers/me         | Seller   | Get own profile + status |

### Admin Endpoints
| Method | Endpoint                         | Auth  | Description               |
|--------|----------------------------------|-------|---------------------------|
| POST   | /api/admin/login                 | None  | Admin login → JWT         |
| GET    | /api/admin/stats                 | Admin | Dashboard summary stats   |
| GET    | /api/admin/sellers               | Admin | List sellers (filterable) |
| GET    | /api/admin/sellers/:id           | Admin | Single seller + audit log |
| POST   | /api/admin/sellers/:id/approve   | Admin | Approve + email seller    |
| POST   | /api/admin/sellers/:id/reject    | Admin | Reject + email seller     |
| POST   | /api/admin/sellers/:id/suspend   | Admin | Suspend seller account    |

### Query Parameters (GET /api/admin/sellers)
- `?status=pending|approved|rejected|suspended`
- `?search=keyword`
- `?page=1&limit=20`

---

## 📧 Email Setup (Gmail)

1. Enable 2FA on your Gmail account
2. Go to Google Account → Security → App Passwords
3. Create an App Password for "Mail"
4. Use that 16-character password as `MAIL_PASS` in `.env`

For production, use a transactional email service like **SendGrid**, **Mailgun**, or **Amazon SES**.

---

## 📋 Seller Registration Form Fields

**Personal:** First name, last name, email, phone, password

**Business:** Business name, registration number, address, business type, product category, website URL, social media URL

**Identity:** ID document upload (JPG/PNG/PDF, max 5MB)

**Business Types:** Individual | Pty Ltd | Sole Proprietor | Wholesale Supplier | AI Service Provider

---

## 🔄 Approval Workflow

```
Seller registers → status: "pending"
  → Email to seller: "Application received"
  → Email to admin: "New application"

Admin approves → status: "approved"
  → Email to seller: "You're approved! Login to your dashboard"
  → Logged in approval_log table

Admin rejects → status: "rejected"
  → Email to seller: "Application rejected" + reason
  → Logged in approval_log table

Admin suspends → status: "suspended"
  → Seller cannot login
  → Logged in approval_log table
```

---

## ✅ What's Implemented (Priority 1 + 2)

- [x] Seller registration with validation
- [x] ID document upload
- [x] Email confirmation on registration
- [x] Admin notified on new application
- [x] Seller login with JWT
- [x] Admin login with separate JWT
- [x] Admin dashboard — stats overview
- [x] Admin list sellers with filter + search
- [x] Admin view seller detail + audit log
- [x] Approve seller → email sent
- [x] Reject seller with reason → email sent
- [x] Suspend seller
- [x] Seller dashboard shows status
- [x] Rate limiting on all auth routes

---

## 🗓 Next Priorities (Roadmap)

| Priority | Feature                         | Status   |
|----------|---------------------------------|----------|
| 3        | Buyer trust verification        | Next      |
| 4        | Commission automation           | Planned   |
| 5        | Full dashboards (orders, stats) | Planned   |
| 6        | PDF contracts + QR verification | Planned   |
| 7        | Public company trust page       | Planned   |
| 8        | Full marketplace system         | Planned   |

---

## 💡 Notes

- All uploaded ID documents are stored in `./uploads/` and only accessible to authenticated admins
- Passwords are hashed with bcrypt (12 rounds)
- Separate JWT secrets for sellers vs admins
- All approval/rejection actions are logged in `approval_log` for full audit trail
- Email sending is non-blocking (failures won't break the API)

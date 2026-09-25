<div align="center">

# 🛡️ OutlineAdmin Installer

**نصب خودکار و امن OutlineAdmin روی سرور شخصی شما**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Caddy](https://img.shields.io/badge/Caddy-1F88C0?logo=caddy&logoColor=white)](https://caddyserver.com/)

یک اسکریپت کامل برای نصب OutlineAdmin روی VPS شخصی، با SSL خودکار و دسترسی امن HTTPS.

</div>

---

## ✨ ویژگی‌ها

<table>
<tr>
<td width="50%">

### 🐳 استقرار خودکار
- نصب خودکار **Docker** و **Docker Compose**
- آخرین نسخه پایدار **OutlineAdmin**
- وب‌سرور سبک **Caddy** به عنوان Reverse Proxy
- نصب idempotent (اجرای مجدد خراب نمی‌شه)

</td>
<td width="50%">

### 🔐 امنیت پیشرفته
- **SSL خودکار** با Let's Encrypt
- ورود فقط با **رمز عبور** (بدون نیاز به نام کاربری)
- تغییر رمز بدون ذخیره در تاریخچه شل
- `credentials.txt` با دسترسی محدود

</td>
</tr>
<tr>
<td width="50%">

### 🎯 سادگی استفاده
- نصب با **یک دستور**
- دریافت اطلاعات ورود در پایان نصب
- دستور تغییر رمز به‌صورت تعاملی
- مناسب برای سرورهای تازه و تمیز

</td>
<td width="50%">

### 📊 مدیریت آسان
- مشاهده وضعیت سرویس‌ها با یک دستور
- لاگ‌های Caddy در دسترس
- پنل مدیریتی سبک و سریع
- بدون نیاز به تنظیمات پیچیده

</td>
</tr>
</table>

---

## ⚡ نصب سریع

فقط کافیه این یه دستور رو روی VPS تازه و تمیز (Ubuntu 22.04 یا 24.04) اجرا کنی:

```bash
curl -fsSL https://raw.githubusercontent.com/forouzanexchange-sys/outline-admin-installer/main/install.sh -o install.sh && bash -n install.sh && sudo bash install.sh
```

هنگام نصب، اسکریپت ازت **دامنه** رو می‌پرسه. مثلاً:
```
outline.yourdomain.com
```

---

## 📋 پیش‌نیازها

<div align="center">

| مورد | حداقل | توصیه‌شده |
|:---:|:---:|:---:|
| 🐧 **سیستم‌عامل** | Ubuntu 22.04 | Ubuntu 24.04 |
| 💾 **رم** | 1 GB | 2 GB |
| 💿 **فضا** | 5 GB | 10 GB |
| 🌐 **دامنه** | A Record به IPv4 | A + AAAA |
| 🔓 **پورت‌ها** | 80, 443 | 22, 80, 443 |

</div>

### 🌐 تنظیم DNS

قبل از اجرا، مطمئن شو رکورد DNS دامنه‌ت به IP سرور اشاره می‌کنه:

```
نوع: A (یا AAAA برای IPv6)
نام: outline
مقدار: IP سرور VPS
TTL: خودکار
```

> ⚠️ **نکته:** این اسکریپت **خود Outline Server را نصب نمی‌کند**. پس از نصب، اطلاعات API سرور Outline خود را در پنل اضافه کنید.

---

## 🚪 ورود به پنل

در پایان نصب، **آدرس پنل** و **رمز ورود** نمایش داده می‌شن.

> 💡 **نام کاربری لازم نیست؛ فقط رمز را وارد کنید.**

برای مشاهده اطلاعات ورود ذخیره‌شده هنگام نصب:

```bash
sudo cat /opt/outline-admin/credentials.txt
```

> 🔒 رمز و فایل اطلاعات ورود را منتشر نکنید.

---

## 🔑 تغییر رمز ورود پنل

تمام دستور چندخطی زیر را **یک‌جا** در ترمینال سرور اجرا کنید. سپس رمز جدید را وارد کرده و Enter بزنید. **رمز هنگام تایپ نمایش داده نمی‌شود.**

```bash
cd /opt/outline-admin && (
  IFS= read -r -s -p 'New password: ' NEW_PASSWORD
  printf '\n'
  if [ -z "$NEW_PASSWORD" ]; then
    printf 'Password must not be empty.\n'
    exit 1
  fi
  sudo docker compose exec -T admin npm run password:change -- "$NEW_PASSWORD"
)
```

پیام **`Password updated successfully.`** تأیید می‌کند رمز تغییر کرده است. سپس با رمز جدید وارد پنل شوید.

### ⚠️ نکات امنیتی

- ✅ رمز واردشده در **تاریخچه دستورات شل ذخیره نمی‌شود**
- ⚠️ `npm` ممکن است رمز را در خروجی ترمینال نمایش دهد؛ **خروجی یا تصویر آن را منتشر نکنید**
- ℹ️ فایل `/opt/outline-admin/credentials.txt` با این دستور **خودکار به‌روز نمی‌شود**
- ℹ️ ویرایش `credentials.txt` به‌تنهایی رمز واقعی پنل را تغییر نمی‌دهد

---

## 🛡️ لایه‌های امنیتی خودکار

اسکریپت این کارها رو **به صورت خودکار** انجام می‌ده:

- ✅ **UFW Firewall**: فقط پورت‌های 22، 80، 443 باز می‌شن
- ✅ **Fail2ban**: IP های مشکوک بعد از ۵ تلاش ناموفق، ۱ ساعت بلاک می‌شن
- ✅ **SSL خودکار**: Caddy گواهی Let's Encrypt رو خودکار مدیریت می‌کنه
- ✅ **Bind داخلی**: پنل admin فقط از `127.0.0.1:3000` در دسترسه (از بیرون فقط از طریق HTTPS)
- ✅ **پسورد قوی**: ۴۸ کاراکتر hex به صورت تصادفی تولید می‌شه
- ✅ **فایل credentials**: با `chmod 0600` محافظت می‌شه

---

## 🛠️ دستورات مفید

بعد از نصب، می‌تونی از این دستورات استفاده کنی:

```bash
# بررسی وضعیت سرویس‌ها
cd /opt/outline-admin && sudo docker compose ps

# مشاهده لاگ Caddy
cd /opt/outline-admin && sudo docker compose logs --tail=80 caddy

# مشاهده لاگ Admin
cd /opt/outline-admin && sudo docker compose logs --tail=80 admin

# ری‌استارت سرویس‌ها
cd /opt/outline-admin && sudo docker compose restart

# توقف سرویس‌ها
cd /opt/outline-admin && sudo docker compose down

# وضعیت فایروال
sudo ufw status numbered

# وضعیت Fail2ban (SSH)
sudo fail2ban-client status sshd

# آنبن کردن یه IP
sudo fail2ban-client set sshd unbanip 1.2.3.4
```

---

## 📁 ساختار پروژه

```
/opt/outline-admin/
├── Caddyfile              # پیکربندی Reverse Proxy
├── compose.yaml           # تعریف سرویس‌ها
├── credentials.txt        # اطلاعات ورود (محرمانه)
└── volumes/
    ├── caddy_data/        # گواهی‌های SSL
    ├── caddy_config/      # پیکربندی Caddy
    ├── admin_data/        # داده‌های OutlineAdmin
    └── admin_logs/        # لاگ‌های OutlineAdmin
```

---

## 🔧 پس از نصب

1. پنل را در مرورگر باز کن: `https://outline.yourdomain.com`
2. با رمزی که در `credentials.txt` ذخیره شده وارد شو
3. اطلاعات API سرور Outline خودت را در پنل اضافه کن

---

## ❓ عیب‌یابی

<details>
<summary><b>🔴 صفحه پنل باز نمی‌شه</b></summary>

- مطمئن شو دامنه به IP سرور اشاره می‌کنه: `dig AAAA your-domain.com +short`
- لاگ Caddy رو ببین: `cd /opt/outline-admin && sudo docker compose logs --tail=80 caddy`
- مطمئن شو پورت‌های 80 و 443 از بیرون قابل دسترسن

</details>

<details>
<summary><b>🟡 خطای 502 Bad Gateway</b></summary>

- مطمئن شو سرویس admin در حال اجراست: `cd /opt/outline-admin && sudo docker compose ps`
- اگه تازه راه افتاده، ۳۰ ثانیه صبر کن
- اگه بازم مشکل داره: `cd /opt/outline-admin && sudo docker compose restart admin`

</details>

<details>
<summary><b>🟠 SSL دریافت نشد</b></summary>

- مطمئن شو دامنه به IP سرور اشاره می‌کنه
- اگه دامنه تو Cloudflare هست، موقتاً پروکسی (ابر نارنجی) رو خاموش کن
- مطمئن شو پورت 80 از بیرون قابل دسترسیه

</details>

<details>
<summary><b>🔵 رمز ورود رو فراموش کردم</b></summary>

```bash
sudo cat /opt/outline-admin/credentials.txt
```

اگه رمز رو تغییر داده بودی، از دستور [تغییر رمز](#-تغییر-رمز-ورود-پنل) استفاده کن.

</details>

<details>
<summary><b>🔴 IP من توسط Fail2ban بلاک شده</b></summary>

اگه IP خودت رو اشتباهی بلاک کردی:

```bash
sudo fail2ban-client set sshd unbanip YOUR_IP
```

برای دیدن لیست IP های بلاک‌شده:

```bash
sudo fail2ban-client status sshd
```

</details>

---

## 📜 مجوز

این پروژه تحت مجوز **MIT** منتشر شده است.

---

<div align="center">

### ✦ نویسندگان اسکریپت ✦

<table>
<tr>
<td align="center" width="50%">

### 🌟 کیومرث فروزان

*معمار و طراح اسکریپت*

</td>
<td align="center" width="50%">

### 🌟 آرش

*توسعه‌دهنده و پیاده‌ساز*

</td>
</tr>
</table>

<br>

⭐ اگه این پروژه به کارت اومد، یه ستاره بده

</div>

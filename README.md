# OutlineAdmin Installer

نصب OutlineAdmin به همراه Caddy برای دسترسی امن HTTPS به پنل مدیریت.

این اسکریپت خود Outline Server را نصب نمی‌کند. پس از نصب، اطلاعات API سرور Outline خود را در پنل اضافه کنید.

## پیش‌نیازها

- سرور تازه Ubuntu 22.04 یا 24.04
- دسترسی root یا sudo
- دامنه یا زیردامنه با رکورد A متصل به IPv4 سرور
- پورت‌های TCP 80 و 443 آزاد و قابل‌دسترسی باشند

اگر برای دامنه رکورد AAAA دارید، اتصال IPv6 سرور باید سالم باشد.

## نصب

هشدار: این اسکریپت با دسترسی مدیریتی اجرا می‌شود. فقط روی سرور تازه و بدون پنل فعال نصب کنید.

دستور زیر را در ترمینال سرور اجرا کنید:

    curl -fsSL https://raw.githubusercontent.com/forouzanexchange-sys/outline-admin-installer/main/install.sh -o install.sh && bash -n install.sh && sudo bash install.sh

هنگام درخواست، دامنه خود را وارد کنید.

## ورود به پنل

در پایان نصب، آدرس پنل و رمز ورود نمایش داده می‌شوند.

نام کاربری لازم نیست؛ فقط رمز را وارد کنید.

برای مشاهده دوباره اطلاعات ورود، این دستور را در ترمینال سرور اجرا کنید:

    sudo cat /opt/outline-admin/credentials.txt

رمز و فایل اطلاعات ورود را منتشر نکنید.

## بررسی وضعیت سرویس‌ها

این دستور را در ترمینال سرور اجرا کنید:

    cd /opt/outline-admin && sudo docker compose ps

## مشاهده لاگ Caddy

این دستور را در ترمینال سرور اجرا کنید:

    cd /opt/outline-admin && sudo docker compose logs --tail=80 caddy

## پس از نصب

پنل را در مرورگر باز کنید، وارد شوید و اطلاعات API سرور Outline خود را اضافه کنید.

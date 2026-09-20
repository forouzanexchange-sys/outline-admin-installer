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

برای مشاهده اطلاعات ورود ذخیره‌شده هنگام نصب، این دستور را اجرا کنید:

    sudo cat /opt/outline-admin/credentials.txt

رمز و فایل اطلاعات ورود را منتشر نکنید. اگر رمز را تغییر داده باشید، این فایل ممکن است همچنان رمز قبلی را نشان دهد.

## تغییر رمز ورود پنل

تمام دستور چندخطی زیر را یک‌جا در ترمینال سرور اجرا کنید. سپس رمز جدید را وارد کرده و Enter بزنید. رمز هنگام تایپ نمایش داده نمی‌شود.

    cd /opt/outline-admin && (
      IFS= read -r -s -p 'New password: ' NEW_PASSWORD
      printf '\n'
      if [ -z "$NEW_PASSWORD" ]; then
        printf 'Password must not be empty.\n'
        exit 1
      fi
      sudo docker compose exec -T admin npm run password:change -- "$NEW_PASSWORD"
    )

پیام Password updated successfully. تأیید می‌کند رمز تغییر کرده است. سپس با رمز جدید وارد پنل شوید.

نکات امنیتی:

- رمز واردشده در تاریخچه دستورات شِل ذخیره نمی‌شود.
- npm ممکن است رمز را در خروجی ترمینال نمایش دهد؛ خروجی یا تصویر آن را منتشر نکنید.
- فایل /opt/outline-admin/credentials.txt با این دستور خودکار به‌روز نمی‌شود.
- ویرایش credentials.txt به‌تنهایی رمز واقعی پنل را تغییر نمی‌دهد.

## بررسی وضعیت سرویس‌ها

این دستور را در ترمینال سرور اجرا کنید:

    cd /opt/outline-admin && sudo docker compose ps

## مشاهده لاگ Caddy

این دستور را در ترمینال سرور اجرا کنید:

    cd /opt/outline-admin && sudo docker compose logs --tail=80 caddy

## پس از نصب

پنل را در مرورگر باز کنید، وارد شوید و اطلاعات API سرور Outline خود را اضافه کنید.

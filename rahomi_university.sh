#!/bin/bash
TARGET="https://almamonuc.edu.iq"
DOMAIN="almamonuc.edu.iq"
REPORT="rahomi_university_scan_report.txt"

echo "[+] RAHOMI UNIVERSITY HUNTER v1 - Start" > $REPORT
date >> $REPORT
echo "الموقع: $TARGET" >> $REPORT
echo "--------------------------------------------------" >> $REPORT

echo "[1] تحليل البنية بتقنية whatweb..." | tee -a $REPORT
whatweb $TARGET >> $REPORT

echo "[2] استخراج النطاقات الفرعية..." | tee -a $REPORT
subfinder -d $DOMAIN -silent > subdomains.txt
cat subdomains.txt >> $REPORT

echo "[3] فحص النطاقات الفرعية..." | tee -a $REPORT
httpx -l subdomains.txt -status -title -tech-detect >> $REPORT

echo "[4] تحليل الأرشيف Wayback..." | tee -a $REPORT
waybackurls $DOMAIN > wayback.txt
cat wayback.txt | grep -Ei "admin|upload|login|config|php" >> $REPORT

echo "[5] فحص الثغرات العامة باستخدام nuclei..." | tee -a $REPORT
nuclei -u $TARGET -t cves/ >> $REPORT

echo "[6] فحص المسارات والملفات المخفية..." | tee -a $REPORT
dirsearch -u $TARGET -e php,html,zip >> $REPORT

echo "[7] استخراج الإيميلات العامة..." | tee -a $REPORT
theHarvester -d $DOMAIN -b bing -f harvester_$DOMAIN.html
echo "نتائج theHarvester محفوظة في harvester_$DOMAIN.html" >> $REPORT

echo "[8] تحليل صفحات إدارية متوقعة..." | tee -a $REPORT
for path in admin login dashboard config backup uploads; do
  curl -s -o /dev/null -w "$path => %{http_code}\\n" "$TARGET/$path" >> $REPORT
done

echo "[✔] الانتهاء من التحليل." | tee -a $REPORT
echo "تم حفظ التقرير في: $REPORT"

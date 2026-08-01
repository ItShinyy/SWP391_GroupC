# Manage local conf here (all gitignored except *.example).
#
# Java (Tomcat)
#   DermAI/local.properties              ← secrets + PAYMENT_API_BASE_URL
#   DermAI/local.properties.example      ← template (safe to commit)
#
# Node payment-service
#   DermAI/payment-service/.env.local           ← DB + VNP_* secrets (copied from Tempo)
#   DermAI/payment-service/.env.local.example   ← template
#
# Nginx (optional, port 80)
#   DermAI/nginx/conf/nginx.conf
#
# After copy from Tempo:
#   1. Edit payment-service/.env.local if DB password / VNPay codes differ
#   2. Keep Derma AI/Google/Cloudinary in local.properties (do not overwrite from Tempo)
#   3. Prefer APP_BASE_URL=http://localhost/DermAI when Nginx is running
#
# Never commit: local.properties, .env.local, node_modules, nginx logs/pid

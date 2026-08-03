        </main>
    </div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        fetch('${pageContext.request.contextPath}/admin/notifications?format=count')
            .then(res => res.json())
            .then(data => {
                const badge = document.getElementById('admin-notif-badge');
                if (badge && data.unread > 0) {
                    badge.textContent = data.unread > 99 ? '99+' : data.unread;
                    badge.classList.remove('d-none');
                }
            })
            .catch(err => console.error('Failed to fetch admin notifications', err));
    });
</script>
</body>
</html>

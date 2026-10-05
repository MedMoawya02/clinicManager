<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="com.clinicmanager.model.User" %>
<%@ page import="com.clinicmanager.dto.UserDTO" %>
<%!
    // Escapes values before printing them in HTML (prevents XSS)
    private static String esc(Object o) {
        if (o == null) return "";
        return o.toString()
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private static String initials(String s) {
        if (s == null || s.isBlank()) return "?";
        String[] p = s.trim().split("[\\s@._-]+");
        String r = p[0].substring(0, 1);
        if (p.length > 1 && !p[1].isEmpty()) r += p[1].substring(0, 1);
        return r.toUpperCase();
    }

    private static String roleLabel(String role) {
        if (role == null || role.isEmpty()) return "-";
        String r = role.replace('_', ' ').toLowerCase();
        return Character.toUpperCase(r.charAt(0)) + r.substring(1);
    }

    private static String roleClass(String role) {
        String r = role == null ? "" : role.toUpperCase();
        if (r.contains("ADMIN")) return "r-admin";
        if (r.contains("DOCTOR") || r.contains("MEDECIN") || r.contains("MÉDECIN")) return "r-doctor";
        if (r.contains("NURSE") || r.contains("INFIRM")) return "r-nurse";
        if (r.contains("RECEPTION") || r.contains("SECRET")) return "r-reception";
        if (r.contains("PATIENT")) return "r-patient";
        return "r-other";
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard Admin – ClinicManager</title>
    <style>
        :root {
            --primary: #0b6e8a;
            --primary-dark: #084c61;
            --primary-light: #e6f3f7;
            --accent: #14b8a6;
            --text: #1f2937;
            --muted: #6b7280;
            --border: #e3e9ee;
            --bg: #f3f7f9;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: "Segoe UI", system-ui, -apple-system, Roboto, Arial, sans-serif;
            color: var(--text);
            background: var(--bg);
            display: flex;
            min-height: 100vh;
        }

        /* ---------- Sidebar ---------- */
        .sidebar {
            width: 250px; flex: none;
            background: linear-gradient(170deg, var(--primary) 0%, var(--primary-dark) 100%);
            color: #fff;
            padding: 28px 18px;
            display: flex; flex-direction: column;
            position: sticky; top: 0; height: 100vh;
        }
        .logo { display: flex; align-items: center; gap: 11px; padding: 0 8px 28px; }
        .logo-icon {
            width: 40px; height: 40px; border-radius: 11px;
            background: rgba(255,255,255,.15);
            display: grid; place-items: center;
        }
        .logo-text { font-size: 19px; font-weight: 700; }
        .logo-text span { font-weight: 400; opacity: .85; }

        .nav-title {
            font-size: 11px; letter-spacing: 1px; text-transform: uppercase;
            opacity: .55; padding: 0 12px; margin: 6px 0 8px;
        }
        .nav a {
            display: flex; align-items: center; gap: 12px;
            color: rgba(255,255,255,.82);
            text-decoration: none; font-size: 14.5px;
            padding: 11px 12px; border-radius: 10px; margin-bottom: 4px;
            transition: background .15s;
        }
        .nav a:hover { background: rgba(255,255,255,.1); color: #fff; }
        .nav a.active { background: rgba(255,255,255,.18); color: #fff; font-weight: 600; }

        .sidebar .spacer { flex: 1; }
        .sidebar .logout { margin-top: auto; border-top: 1px solid rgba(255,255,255,.15); padding-top: 14px; }

        /* ---------- Main ---------- */
        .main { flex: 1; min-width: 0; padding: 28px 36px 40px; }

        .topbar {
            display: flex; align-items: center; justify-content: space-between;
            gap: 16px; flex-wrap: wrap; margin-bottom: 28px;
        }
        .topbar h1 { font-size: 24px; color: var(--primary-dark); }
        .topbar p { color: var(--muted); font-size: 14px; margin-top: 3px; }

        .user-chip {
            display: flex; align-items: center; gap: 10px;
            background: #fff; border: 1px solid var(--border);
            padding: 6px 14px 6px 6px; border-radius: 40px; font-size: 13.5px;
        }
        .avatar {
            width: 32px; height: 32px; border-radius: 50%;
            background: var(--primary); color: #fff;
            display: grid; place-items: center;
            font-size: 12.5px; font-weight: 600; flex: none;
        }
        .user-chip small { display: block; color: var(--muted); font-size: 11.5px; line-height: 1.2; }
        .user-chip strong { font-weight: 600; line-height: 1.2; }

        /* ---------- Stat cards ---------- */
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 16px; margin-bottom: 26px; }
        .stat {
            background: #fff; border: 1px solid var(--border);
            border-radius: 14px; padding: 18px 20px;
            display: flex; align-items: center; gap: 16px;
        }
        .stat-icon { width: 46px; height: 46px; border-radius: 12px; display: grid; place-items: center; flex: none; }
        .stat-icon.blue  { background: var(--primary-light); color: var(--primary); }
        .stat-icon.green { background: #e3f8ee; color: #15803d; }
        .stat-icon.red   { background: #fdeceb; color: #b42318; }
        .stat-icon.teal  { background: #dcf7f3; color: #0f766e; }
        .stat .num { font-size: 26px; font-weight: 700; line-height: 1.1; }
        .stat .lbl { font-size: 13px; color: var(--muted); margin-top: 2px; }

        /* ---------- Panel / table ---------- */
        .panel { background: #fff; border: 1px solid var(--border); border-radius: 14px; overflow: hidden; }
        .panel-head {
            display: flex; align-items: center; justify-content: space-between;
            gap: 12px; flex-wrap: wrap; padding: 18px 22px; border-bottom: 1px solid var(--border);
        }
        .panel-head h2 { font-size: 17px; color: var(--primary-dark); }

        .tools { display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }
        .tools input, .tools select {
            height: 40px; border: 1.5px solid var(--border); border-radius: 10px;
            padding: 0 12px; font: inherit; font-size: 14px; background: #fff; color: var(--text);
        }
        .tools input { width: 220px; }
        .tools input:focus, .tools select:focus {
            outline: none; border-color: var(--primary); box-shadow: 0 0 0 4px rgba(11,110,138,.14);
        }
        .btn {
            display: inline-flex; align-items: center; gap: 8px;
            height: 40px; padding: 0 18px; border-radius: 10px; border: none;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #fff; text-decoration: none; font-size: 14px; font-weight: 600;
            transition: box-shadow .2s;
        }
        .btn:hover { box-shadow: 0 8px 18px rgba(11,110,138,.28); }

        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; font-size: 14.5px; }
        thead th {
            text-align: left; font-size: 12px; text-transform: uppercase; letter-spacing: .6px;
            color: var(--muted); background: #f8fafb; padding: 12px 22px; white-space: nowrap;
        }
        tbody td { padding: 14px 22px; border-top: 1px solid var(--border); vertical-align: middle; }
        tbody tr:hover { background: #f8fbfc; }
        .id { color: var(--muted); font-variant-numeric: tabular-nums; }
        .person { display: flex; align-items: center; gap: 12px; }
        .person .avatar { width: 36px; height: 36px; background: var(--primary-light); color: var(--primary); }

        .badge {
            display: inline-block; padding: 4px 11px; border-radius: 20px;
            font-size: 12.5px; font-weight: 600; white-space: nowrap;
        }
        .r-admin     { background: #ede9fe; color: #5b21b6; }
        .r-doctor    { background: #dbeafe; color: #1d4ed8; }
        .r-nurse     { background: #dcf7f3; color: #0f766e; }
        .r-reception { background: #fef3c7; color: #92400e; }
        .r-patient   { background: #fce7f3; color: #be185d; }
        .r-other     { background: #eef1f4; color: #475569; }

        .status { display: inline-flex; align-items: center; gap: 7px; font-size: 13.5px; }
        .status i { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
        .status.on i  { background: #16a34a; }
        .status.off i { background: #b42318; }
        .status.off { color: #b42318; }

        .empty { text-align: center; padding: 54px 20px; color: var(--muted); }
        .empty svg { color: #b8c4cc; margin-bottom: 10px; }
        #noMatch { display: none; }

        /* ---------- Responsive ---------- */
        @media (max-width: 860px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; height: auto; position: static; flex-direction: row; align-items: center; padding: 14px 16px; gap: 10px; flex-wrap: wrap; }
            .logo { padding: 0; }
            .nav-title, .sidebar .spacer { display: none; }
            .nav { display: flex; gap: 4px; }
            .nav a { margin: 0; padding: 9px 11px; font-size: 13.5px; }
            .sidebar .logout { margin: 0 0 0 auto; border: none; padding: 0; }
            .main { padding: 20px 16px 32px; }
            .tools input { width: 100%; }
            .tools { width: 100%; }
        }
    </style>
</head>
<body>
<%
    UserDTO current = (UserDTO) session.getAttribute("user");
    if (current == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    @SuppressWarnings("unchecked")
    List<User> users = (List<User>) request.getAttribute("users");

    int total = 0, activeCount = 0;
    Map<String, Integer> roleCounts = new LinkedHashMap<>();
    if (users != null) {
        for (User u : users) {
            total++;
            if (u.isActive()) activeCount++;
            String r = String.valueOf(u.getRole());
            roleCounts.merge(r, 1, Integer::sum);
        }
    }
    int inactiveCount = total - activeCount;
    String ctx = request.getContextPath();
%>

<!-- ========== Sidebar ========== -->
<aside class="sidebar">
    <div class="logo">
        <div class="logo-icon">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
        </div>
        <div class="logo-text">Clinic<span>Manager</span></div>
    </div>

    <div class="nav-title">Administration</div>
    <nav class="nav">
        <a href="<%= ctx %>/admin/dashboard" class="active">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg>
            Tableau de bord
        </a>
        <a class="btn" href="${pageContext.request.contextPath}/admin/create-user">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M19 8v6M22 11h-6"/></svg>
            Créer un utilisateur
        </a>
    </nav>

    <div class="spacer"></div>

    <div class="nav logout">
        <a href="<%= ctx %>/logout">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9"/></svg>
            Déconnexion
        </a>
    </div>
</aside>

<!-- ========== Main ========== -->
<main class="main">

    <div class="topbar">
        <div>
            <h1>Dashboard Administrateur</h1>
            <p>Vue d'ensemble des comptes et des rôles de la clinique.</p>
        </div>
        <div class="user-chip">
            <div class="avatar"><%= esc(initials(current.email())) %></div>
            <div>
                <small>Connecté en tant que</small>
                <strong><%= esc(current.email()) %></strong>
            </div>
        </div>
    </div>

    <!-- Stats -->
    <section class="stats">
        <div class="stat">
            <div class="stat-icon blue">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/></svg>
            </div>
            <div><div class="num"><%= total %></div><div class="lbl">Utilisateurs</div></div>
        </div>
        <div class="stat">
            <div class="stat-icon green">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><path d="M22 4L12 14.01l-3-3"/></svg>
            </div>
            <div><div class="num"><%= activeCount %></div><div class="lbl">Comptes actifs</div></div>
        </div>
        <div class="stat">
            <div class="stat-icon red">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M4.9 4.9l14.2 14.2"/></svg>
            </div>
            <div><div class="num"><%= inactiveCount %></div><div class="lbl">Comptes inactifs</div></div>
        </div>
        <div class="stat">
            <div class="stat-icon teal">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l8 3v6c0 5-3.5 9-8 11-4.5-2-8-6-8-11V5l8-3z"/></svg>
            </div>
            <div><div class="num"><%= roleCounts.size() %></div><div class="lbl">Rôles utilisés</div></div>
        </div>
    </section>

    <!-- Users -->
    <section class="panel">
        <div class="panel-head">
            <h2>Liste des utilisateurs</h2>
            <div class="tools">
                <input type="search" id="q" placeholder="Rechercher un nom ou un e-mail…" aria-label="Rechercher">
                <select id="roleFilter" aria-label="Filtrer par rôle">
                    <option value="">Tous les rôles (<%= total %>)</option>
                    <% for (Map.Entry<String, Integer> e : roleCounts.entrySet()) { %>
                    <option value="<%= esc(e.getKey()) %>"><%= esc(roleLabel(e.getKey())) %> (<%= e.getValue() %>)</option>
                    <% } %>
                </select>
                <a class="btn" href="${pageContext.request.contextPath}/admin/create-user">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
                    Créer un utilisateur
                </a>
            </div>
        </div>

        <% if (users == null || users.isEmpty()) { %>
        <div class="empty">
            <svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
            <p>Aucun utilisateur.</p>
        </div>
        <% } else { %>
        <div class="table-wrap">
            <table id="usersTable">
                <thead>
                <tr><th>ID</th><th>Nom</th><th>Email</th><th>Rôle</th><th>Actif</th></tr>
                </thead>
                <tbody>
                <% for (User u : users) {
                    String fullName = u.getFullName();
                    String role = String.valueOf(u.getRole());
                %>
                <tr data-role="<%= esc(role) %>"
                    data-search="<%= esc(((fullName != null ? fullName : "") + " " + u.getEmail()).toLowerCase()) %>">
                    <td class="id">#<%= u.getId() %></td>
                    <td>
                        <div class="person">
                            <div class="avatar"><%= esc(initials(fullName != null ? fullName : u.getEmail())) %></div>
                            <span><%= fullName != null ? esc(fullName) : "-" %></span>
                        </div>
                    </td>
                    <td><%= esc(u.getEmail()) %></td>
                    <td><span class="badge <%= roleClass(role) %>"><%= esc(roleLabel(role)) %></span></td>
                    <td>
                        <% if (u.isActive()) { %>
                        <span class="status on"><i></i>Oui</span>
                        <% } else { %>
                        <span class="status off"><i></i>Non</span>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <div class="empty" id="noMatch">
                <p>Aucun résultat pour cette recherche.</p>
            </div>
        </div>
        <% } %>
    </section>
</main>

<script>
    (function () {
        var q = document.getElementById('q');
        var sel = document.getElementById('roleFilter');
        var rows = document.querySelectorAll('#usersTable tbody tr');
        var noMatch = document.getElementById('noMatch');
        if (!rows.length) return;

        function apply() {
            var term = q.value.trim().toLowerCase();
            var role = sel.value;
            var shown = 0;
            rows.forEach(function (tr) {
                var ok = (!term || tr.dataset.search.indexOf(term) !== -1)
                    && (!role || tr.dataset.role === role);
                tr.style.display = ok ? '' : 'none';
                if (ok) shown++;
            });
            noMatch.style.display = shown ? 'none' : 'block';
        }
        q.addEventListener('input', apply);
        sel.addEventListener('change', apply);
    })();
</script>
</body>
</html>

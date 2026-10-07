<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.clinicmanager.dto.UserDTO" %>
<%@ page import="com.clinicmanager.model.Role" %>
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

    private static String attr(HttpServletRequest request, String name) {
        Object v = request.getAttribute(name);
        return v == null ? "" : v.toString();
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Créer un utilisateur – ClinicManager</title>
    <style>
        :root {
            --primary: #0b6e8a;
            --primary-dark: #084c61;
            --primary-light: #e6f3f7;
            --accent: #14b8a6;
            --text: #1f2937;
            --muted: #6b7280;
            --border: #e3e9ee;
            --field-border: #d5dde3;
            --bg: #f3f7f9;
            --danger: #b42318;
            --danger-bg: #fef3f2;
            --danger-border: #fecdca;
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
            gap: 16px; flex-wrap: wrap; margin-bottom: 24px;
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

        .breadcrumb { font-size: 13.5px; color: var(--muted); margin-bottom: 8px; }
        .breadcrumb a { color: var(--primary); text-decoration: none; }
        .breadcrumb a:hover { text-decoration: underline; }

        /* ---------- Form card ---------- */
        .panel {
            background: #fff; border: 1px solid var(--border);
            border-radius: 14px; max-width: 900px; overflow: hidden;
        }
        .panel-head { padding: 20px 28px; border-bottom: 1px solid var(--border); }
        .panel-head h2 { font-size: 17px; color: var(--primary-dark); }
        .panel-head p { font-size: 13.5px; color: var(--muted); margin-top: 3px; }
        form { padding: 26px 28px 28px; }

        .alert {
            display: flex; align-items: flex-start; gap: 10px;
            background: var(--danger-bg); border: 1px solid var(--danger-border);
            color: var(--danger); padding: 12px 14px; border-radius: 10px;
            font-size: 14px; margin-bottom: 22px;
        }
        .alert svg { flex: none; margin-top: 1px; }

        .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px 22px; }
        .full { grid-column: 1 / -1; }

        .section-title {
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .6px;
            color: var(--primary);
            border-bottom: 1px solid var(--border);
            padding-bottom: 10px;
            margin: 12px 0 -4px;
            grid-column: 1 / -1;
        }

        .field label.lbl { display: block; font-size: 13.5px; font-weight: 600; margin-bottom: 7px; }
        .field label.lbl .req { color: var(--danger); }
        .hint { font-size: 12.5px; color: var(--muted); margin-top: 6px; }

        .input-wrap { position: relative; }
        .input-wrap .icon {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
            color: var(--muted); display: flex; pointer-events: none;
        }
        .input-wrap input, .input-wrap select {
            width: 100%; height: 46px; padding: 0 44px 0 44px;
            font: inherit; font-size: 15px; color: var(--text);
            border: 1.5px solid var(--field-border); border-radius: 10px; background: #fff;
            transition: border-color .15s, box-shadow .15s;
        }
        .input-wrap select { appearance: none; -webkit-appearance: none; cursor: pointer; }
        .input-wrap .chev {
            position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
            color: var(--muted); pointer-events: none; display: flex;
        }
        .input-wrap input:focus, .input-wrap select:focus {
            outline: none; border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(11,110,138,.14);
        }
        .input-wrap input.invalid { border-color: var(--danger); }
        .toggle {
            position: absolute; right: 8px; top: 50%; transform: translateY(-50%);
            border: none; background: none; cursor: pointer; color: var(--muted);
            padding: 8px; border-radius: 8px; display: flex;
        }
        .toggle:hover { color: var(--primary); background: var(--primary-light); }

        /* strength meter */
        .meter { display: flex; gap: 5px; margin-top: 9px; }
        .meter span { flex: 1; height: 4px; border-radius: 4px; background: #e5eaee; transition: background .2s; }
        .meter.s1 span:nth-child(-n+1) { background: #ef4444; }
        .meter.s2 span:nth-child(-n+2) { background: #f59e0b; }
        .meter.s3 span:nth-child(-n+3) { background: #84cc16; }
        .meter.s4 span:nth-child(-n+4) { background: #16a34a; }
        .match { font-size: 12.5px; margin-top: 6px; min-height: 16px; }
        .match.ok { color: #15803d; }
        .match.ko { color: var(--danger); }

        /* active switch */
        .switch-row {
            display: flex; align-items: center; justify-content: space-between; gap: 16px;
            border: 1.5px solid var(--field-border); border-radius: 10px; padding: 12px 16px;
        }
        .switch-row strong { font-size: 14.5px; display: block; }
        .switch-row small { color: var(--muted); font-size: 12.5px; }
        .switch { position: relative; width: 46px; height: 26px; flex: none; }
        .switch input { opacity: 0; width: 0; height: 0; }
        .switch .slider {
            position: absolute; inset: 0; background: #cbd5db; border-radius: 26px;
            cursor: pointer; transition: background .2s;
        }
        .switch .slider::before {
            content: ""; position: absolute; width: 20px; height: 20px; left: 3px; top: 3px;
            background: #fff; border-radius: 50%; transition: transform .2s;
            box-shadow: 0 1px 3px rgba(0,0,0,.25);
        }
        .switch input:checked + .slider { background: var(--accent); }
        .switch input:checked + .slider::before { transform: translateX(20px); }
        .switch input:focus-visible + .slider { outline: 3px solid rgba(20,184,166,.45); outline-offset: 2px; }

        .actions {
            display: flex; justify-content: flex-end; gap: 12px;
            margin-top: 28px; padding-top: 22px; border-top: 1px solid var(--border);
        }
        .btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px;
            height: 46px; padding: 0 24px; border-radius: 10px;
            font: inherit; font-size: 15px; font-weight: 600; cursor: pointer;
            text-decoration: none; border: none; transition: box-shadow .2s, background .15s;
        }
        .btn-primary { background: linear-gradient(135deg, var(--primary), var(--primary-dark)); color: #fff; }
        .btn-primary:hover { box-shadow: 0 8px 18px rgba(11,110,138,.28); }
        .btn-ghost { background: #fff; color: var(--text); border: 1.5px solid var(--field-border); }
        .btn-ghost:hover { background: #f5f8fa; }
        .btn:focus-visible { outline: 3px solid rgba(20,184,166,.5); outline-offset: 2px; }

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
            .grid { grid-template-columns: 1fr; }
            form { padding: 22px 18px 24px; }
            .panel-head { padding: 18px; }
            .actions { flex-direction: column-reverse; }
            .actions .btn { width: 100%; }
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

    String ctx = request.getContextPath();

    Role[] roles = (Role[]) request.getAttribute("roles");
    if (roles == null) {
        roles = Role.values();
    }

    String fullName = attr(request, "fullName");
    String email    = attr(request, "email");
    String selRole  = attr(request, "role");
    Object activeAttr = request.getAttribute("active");
    boolean active = activeAttr == null || Boolean.parseBoolean(String.valueOf(activeAttr));
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
        <a href="<%= ctx %>/admin/dashboard">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg>
            Tableau de bord
        </a>
        <a href="<%= ctx %>/admin/create-user" class="active">
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
            <div class="breadcrumb"><a href="<%= ctx %>/admin/dashboard">Tableau de bord</a> / Créer un utilisateur</div>
            <h1>Créer un utilisateur</h1>
            <p>Ajoutez un nouveau compte et attribuez-lui un rôle.</p>
        </div>
        <div class="user-chip">
            <div class="avatar"><%= esc(initials(current.email())) %></div>
            <div>
                <small>Connecté en tant que</small>
                <strong><%= esc(current.email()) %></strong>
            </div>
        </div>
    </div>

    <section class="panel">
        <div class="panel-head">
            <h2>Informations du compte</h2>
            <p>Les champs marqués d'un <span style="color:var(--danger)">*</span> sont obligatoires.</p>
        </div>

        <form method="post" action="<%= ctx %>/admin/create-user" id="userForm" novalidate>

            <% if (request.getAttribute("error") != null) { %>
            <div class="alert" role="alert">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/></svg>
                <span><%= esc(request.getAttribute("error")) %></span>
            </div>
            <% } %>

            <div class="grid">

                <!-- Full name -->
                <div class="field full">
                    <label class="lbl" for="fullName">Nom complet <span class="req">*</span></label>
                    <div class="input-wrap">
                        <span class="icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </span>
                        <input type="text" id="fullName" name="fullName" required maxlength="120"
                               autocomplete="off" placeholder="Ex. Dr Amine Benali"
                               value="<%= esc(fullName) %>">
                    </div>
                </div>

                <!-- Email -->
                <div class="field">
                    <label class="lbl" for="email">Adresse e-mail <span class="req">*</span></label>
                    <div class="input-wrap">
                        <span class="icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>
                        </span>
                        <input type="email" id="email" name="email" required autocomplete="off"
                               placeholder="nom@clinique.com" value="<%= esc(email) %>">
                    </div>
                </div>

                <!-- Role -->
                <div class="field">
                    <label class="lbl" for="role">Rôle <span class="req">*</span></label>
                    <div class="input-wrap">
                        <span class="icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l8 3v6c0 5-3.5 9-8 11-4.5-2-8-6-8-11V5l8-3z"/></svg>
                        </span>
                        <select id="role" name="role" required onchange="toggleRoleFields()">
                            <option value="" disabled <%= selRole.isEmpty() ? "selected" : "" %>>Sélectionner un rôle…</option>
                            <% for (Role r : roles) {
                                String rv = r.name(); %>
                            <option value="<%= esc(rv) %>" <%= rv.equals(selRole) ? "selected" : "" %>><%= esc(roleLabel(rv)) %></option>
                            <% } %>
                        </select>
                        <span class="chev">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>
                        </span>
                    </div>
                </div>

                <!-- Password -->
                <div class="field">
                    <label class="lbl" for="password">Mot de passe <span class="req">*</span></label>
                    <div class="input-wrap">
                        <span class="icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 018 0v4"/></svg>
                        </span>
                        <input type="password" id="password" name="password" required minlength="8"
                               autocomplete="new-password" placeholder="Minimum 8 caractères">
                        <button type="button" class="toggle" data-target="password" aria-label="Afficher le mot de passe">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                    <div class="meter" id="meter"><span></span><span></span><span></span><span></span></div>
                    <div class="hint" id="strengthTxt">Utilisez majuscules, chiffres et symboles.</div>
                </div>

                <!-- Confirm password -->
                <div class="field">
                    <label class="lbl" for="confirm">Confirmer le mot de passe <span class="req">*</span></label>
                    <div class="input-wrap">
                        <span class="icon">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 018 0v4"/></svg>
                        </span>
                        <input type="password" id="confirm" name="confirmPassword" required
                               autocomplete="new-password" placeholder="Retapez le mot de passe">
                        <button type="button" class="toggle" data-target="confirm" aria-label="Afficher le mot de passe">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                    <div class="match" id="matchTxt"></div>
                </div>

                <!-- ================= PATIENT FIELDS ================= -->
                <div id="patientFields" class="full" style="display:none">
                    <h3 class="section-title">Informations du patient</h3>
                    <div class="grid">

                        <div class="field">
                            <label class="lbl" for="cin">CIN <span class="req">*</span></label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><circle cx="9" cy="10" r="2"/><path d="M15 9h3M15 13h3M5 16c1-2 3-2 4 0"/></svg>
                                </span>
                                <input type="text" id="cin" name="cin" maxlength="20"
                                       placeholder="Ex. AB123456"
                                       value="<%= esc(attr(request, "cin")) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="genre">Genre <span class="req">*</span></label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M6 21v-2a4 4 0 014-4h4a4 4 0 014 4v2"/></svg>
                                </span>
                                <select id="genre" name="genre">
                                    <option value="" disabled selected>Sélectionner…</option>
                                    <option value="HOMME">Homme</option>
                                    <option value="FEMME">Femme</option>
                                    <option value="AUTRE">Autre</option>
                                </select>
                                <span class="chev">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>
                                </span>
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="nom">Nom <span class="req">*</span></label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                </span>
                                <input type="text" id="nom" name="nom" maxlength="60"
                                       value="<%= esc(attr(request, "nom")) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="prenom">Prénom <span class="req">*</span></label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                </span>
                                <input type="text" id="prenom" name="prenom" maxlength="60"
                                       value="<%= esc(attr(request, "prenom")) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="dateNaissance">Date de naissance <span class="req">*</span></label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 11h18"/></svg>
                                </span>
                                <input type="date" id="dateNaissance" name="dateNaissance"
                                       value="<%= esc(attr(request, "dateNaissance")) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="groupeSanguin">Groupe sanguin</label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2s7 7.5 7 12a7 7 0 11-14 0c0-4.5 7-12 7-12z"/></svg>
                                </span>
                                <select id="groupeSanguin" name="groupeSanguin" data-optional="true">
                                    <option value="">— Non renseigné —</option>
                                    <option value="A_POS">A+</option>
                                    <option value="A_NEG">A-</option>
                                    <option value="B_POS">B+</option>
                                    <option value="B_NEG">B-</option>
                                    <option value="AB_POS">AB+</option>
                                    <option value="AB_NEG">AB-</option>
                                    <option value="O_POS">O+</option>
                                    <option value="O_NEG">O-</option>
                                </select>
                                <span class="chev">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>
                                </span>
                            </div>
                        </div>

                        <div class="field full">
                            <label class="lbl" for="adresse">Adresse</label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13S3 17 3 10a9 9 0 1118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                                </span>
                                <input type="text" id="adresse" name="adresse" maxlength="255"
                                       data-optional="true"
                                       value="<%= esc(attr(request, "adresse")) %>">
                            </div>
                        </div>

                        <div class="field full">
                            <label class="lbl" for="telephonePatient">Téléphone</label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.9v3a2 2 0 01-2.2 2A19.8 19.8 0 012 4.2 2 2 0 014 2h3a2 2 0 012 1.7l.6 3a2 2 0 01-.5 1.7L7.5 10A16 16 0 0014 16.5l1.6-1.6a2 2 0 011.7-.5l3 .6A2 2 0 0122 16.9z"/></svg>
                                </span>
                                <input type="text" id="telephonePatient" name="telephone" maxlength="20"
                                       data-optional="true"
                                       value="<%= esc(attr(request, "telephone")) %>">
                            </div>
                        </div>

                    </div>
                </div>

                <!-- ================= DOCTOR FIELDS ================= -->
                <div id="doctorFields" class="full" style="display:none">
                    <h3 class="section-title">Informations du médecin</h3>
                    <div class="grid">

                        <div class="field">
                            <label class="lbl" for="matricule">Matricule <span class="req">*</span></label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M7 9h4M7 13h10"/></svg>
                                </span>
                                <input type="text" id="matricule" name="matricule" maxlength="30"
                                       placeholder="Ex. MED-001"
                                       value="<%= esc(attr(request, "matricule")) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="titre">Titre</label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="5"/><path d="M20 21a8 8 0 10-16 0"/></svg>
                                </span>
                                <select id="titre" name="titre" data-optional="true">
                                    <option value="">—</option>
                                    <option value="Dr">Dr</option>
                                    <option value="Pr">Pr</option>
                                </select>
                                <span class="chev">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>
                                </span>
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="nomDoc">Nom <span class="req">*</span></label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                </span>
                                <input type="text" id="nomDoc" name="nom" maxlength="60"
                                       value="<%= esc(attr(request, "nom")) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="prenomDoc">Prénom <span class="req">*</span></label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                </span>
                                <input type="text" id="prenomDoc" name="prenom" maxlength="60"
                                       value="<%= esc(attr(request, "prenom")) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="specialite">Spécialité</label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M2 12h20"/></svg>
                                </span>
                                <input type="text" id="specialite" name="specialite" maxlength="80"
                                       data-optional="true"
                                       placeholder="Ex. Cardiologie"
                                       value="<%= esc(attr(request, "specialite")) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="departement">Département</label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 21h18M5 21V7l7-4 7 4v14M9 9h.01M9 13h.01M9 17h.01M15 9h.01M15 13h.01M15 17h.01"/></svg>
                                </span>
                                <input type="text" id="departement" name="departement" maxlength="80"
                                       data-optional="true"
                                       value="<%= esc(attr(request, "departement")) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="emailPro">Email professionnel</label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></svg>
                                </span>
                                <input type="email" id="emailPro" name="emailPro" maxlength="120"
                                       data-optional="true"
                                       value="<%= esc(attr(request, "emailPro")) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label class="lbl" for="telephoneDoc">Téléphone</label>
                            <div class="input-wrap">
                                <span class="icon">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.9v3a2 2 0 01-2.2 2A19.8 19.8 0 012 4.2 2 2 0 014 2h3a2 2 0 012 1.7l.6 3a2 2 0 01-.5 1.7L7.5 10A16 16 0 0014 16.5l1.6-1.6a2 2 0 011.7-.5l3 .6A2 2 0 0122 16.9z"/></svg>
                                </span>
                                <input type="text" id="telephoneDoc" name="telephone" maxlength="20"
                                       data-optional="true"
                                       value="<%= esc(attr(request, "telephone")) %>">
                            </div>
                        </div>

                    </div>
                </div>

                <!-- Active -->
                <div class="field full">
                    <div class="switch-row">
                        <div>
                            <strong>Compte actif</strong>
                            <small>Un compte inactif ne peut pas se connecter.</small>
                        </div>
                        <label class="switch">
                            <input type="checkbox" name="active" value="true" <%= active ? "checked" : "" %>>
                            <span class="slider"></span>
                        </label>
                    </div>
                </div>
            </div>

            <div class="actions">
                <a class="btn btn-ghost" href="<%= ctx %>/admin/dashboard">Annuler</a>
                <button type="submit" class="btn btn-primary">
                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12l5 5L20 7"/></svg>
                    Créer l'utilisateur
                </button>
            </div>
        </form>
    </section>
</main>

<script>
    (function () {
        var pwd = document.getElementById('password');
        var conf = document.getElementById('confirm');
        var meter = document.getElementById('meter');
        var strengthTxt = document.getElementById('strengthTxt');
        var matchTxt = document.getElementById('matchTxt');
        var form = document.getElementById('userForm');

        // show / hide password
        document.querySelectorAll('.toggle').forEach(function (btn) {
            btn.addEventListener('click', function () {
                var input = document.getElementById(btn.dataset.target);
                var show = input.type === 'password';
                input.type = show ? 'text' : 'password';
                btn.setAttribute('aria-label', show ? 'Masquer le mot de passe' : 'Afficher le mot de passe');
            });
        });

        // strength meter
        var labels = ['Très faible', 'Faible', 'Moyen', 'Bon', 'Excellent'];
        pwd.addEventListener('input', function () {
            var v = pwd.value, s = 0;
            if (v.length >= 8) s++;
            if (/[A-Z]/.test(v) && /[a-z]/.test(v)) s++;
            if (/\d/.test(v)) s++;
            if (/[^A-Za-z0-9]/.test(v)) s++;
            meter.className = 'meter' + (v ? ' s' + Math.max(s, 1) : '');
            strengthTxt.textContent = v ? 'Robustesse : ' + labels[v ? Math.max(s, 0) : 0]
                : 'Utilisez majuscules, chiffres et symboles.';
            checkMatch();
        });

        // confirmation match
        function checkMatch() {
            if (!conf.value) { matchTxt.textContent = ''; matchTxt.className = 'match'; conf.classList.remove('invalid'); return true; }
            var ok = pwd.value === conf.value;
            matchTxt.textContent = ok ? 'Les mots de passe correspondent.' : 'Les mots de passe ne correspondent pas.';
            matchTxt.className = 'match ' + (ok ? 'ok' : 'ko');
            conf.classList.toggle('invalid', !ok);
            return ok;
        }
        conf.addEventListener('input', checkMatch);

        // client-side validation
        form.addEventListener('submit', function (e) {
            if (!form.checkValidity() || !checkMatch()) {
                e.preventDefault();
                form.reportValidity();
                if (!checkMatch()) conf.focus();
            }
        });
    })();

    /* ============================================================
       AFFICHAGE CONDITIONNEL PATIENT / DOCTOR
       ============================================================ */
    function toggleRoleFields() {
        var role = document.getElementById('role').value;
        var patientBlk = document.getElementById('patientFields');
        var doctorBlk  = document.getElementById('doctorFields');

        var isPatient = (role === 'PATIENT');
        var isDoctor  = (role === 'DOCTOR');

        patientBlk.style.display = isPatient ? 'block' : 'none';
        doctorBlk.style.display  = isDoctor  ? 'block' : 'none';

        toggleRequired(patientBlk, isPatient);
        toggleRequired(doctorBlk,  isDoctor);
    }

    function toggleRequired(container, required) {
        container.querySelectorAll('input, select').forEach(function (el) {
            if (el.dataset.optional === 'true') return;
            if (required) {
                el.setAttribute('required', 'required');
            } else {
                el.removeAttribute('required');
            }
        });
    }

    document.addEventListener('DOMContentLoaded', toggleRoleFields);
</script>
</body>
</html>
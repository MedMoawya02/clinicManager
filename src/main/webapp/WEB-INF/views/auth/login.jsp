<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    // Escapes user-controlled values before printing them in HTML (prevents XSS)
    private static String esc(Object o) {
        if (o == null) return "";
        return o.toString()
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Connexion – ClinicManager</title>
    <style>
        :root {
            --primary: #0b6e8a;
            --primary-dark: #084c61;
            --primary-light: #e6f3f7;
            --accent: #14b8a6;
            --text: #1f2937;
            --muted: #6b7280;
            --border: #d5dde3;
            --bg: #f3f7f9;
            --danger: #b42318;
            --danger-bg: #fef3f2;
            --danger-border: #fecdca;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: "Segoe UI", system-ui, -apple-system, Roboto, "Helvetica Neue", Arial, sans-serif;
            color: var(--text);
            background: var(--bg);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .card {
            display: flex;
            width: 100%;
            max-width: 960px;
            min-height: 560px;
            background: #fff;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 20px 50px rgba(8, 76, 97, .15);
        }

        /* ---------- Brand panel ---------- */
        .brand {
            flex: 1;
            position: relative;
            padding: 48px 40px;
            color: #fff;
            background: linear-gradient(155deg, var(--primary) 0%, var(--primary-dark) 100%);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            overflow: hidden;
        }
        .brand::before, .brand::after {
            content: "";
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, .06);
        }
        .brand::before { width: 320px; height: 320px; top: -110px; right: -110px; }
        .brand::after  { width: 220px; height: 220px; bottom: -70px; left: -70px; }
        .brand > * { position: relative; z-index: 1; }

        .logo { display: flex; align-items: center; gap: 12px; }
        .logo-icon {
            width: 44px; height: 44px;
            background: rgba(255, 255, 255, .15);
            border-radius: 12px;
            display: grid; place-items: center;
        }
        .logo-text { font-size: 22px; font-weight: 700; letter-spacing: .3px; }
        .logo-text span { font-weight: 400; opacity: .85; }

        .brand h2 { font-size: 28px; line-height: 1.3; font-weight: 600; margin-bottom: 14px; }
        .brand p.lead { font-size: 15px; line-height: 1.6; opacity: .88; margin-bottom: 28px; }

        .features { list-style: none; display: grid; gap: 14px; }
        .features li { display: flex; align-items: center; gap: 12px; font-size: 14.5px; }
        .features .dot {
            width: 28px; height: 28px; flex: none;
            border-radius: 50%;
            background: rgba(20, 184, 166, .25);
            display: grid; place-items: center;
        }

        .brand footer { font-size: 12.5px; opacity: .7; }

        /* ---------- Form panel ---------- */
        .panel {
            flex: 1;
            padding: 56px 48px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .panel h1 { font-size: 26px; font-weight: 700; color: var(--primary-dark); margin-bottom: 6px; }
        .panel .subtitle { color: var(--muted); font-size: 14.5px; margin-bottom: 28px; }

        .alert {
            display: flex; align-items: flex-start; gap: 10px;
            background: var(--danger-bg);
            border: 1px solid var(--danger-border);
            color: var(--danger);
            padding: 12px 14px;
            border-radius: 10px;
            font-size: 14px;
            margin-bottom: 20px;
        }
        .alert svg { flex: none; margin-top: 1px; }

        .field { margin-bottom: 20px; }
        .field label { display: block; font-size: 13.5px; font-weight: 600; margin-bottom: 7px; }

        .input-wrap { position: relative; }
        .input-wrap .icon {
            position: absolute; left: 14px; top: 50%;
            transform: translateY(-50%);
            color: var(--muted);
            display: flex;
            pointer-events: none;
        }
        .input-wrap input {
            width: 100%;
            height: 46px;
            padding: 0 44px 0 44px;
            font-size: 15px;
            font-family: inherit;
            color: var(--text);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            background: #fff;
            transition: border-color .15s, box-shadow .15s;
        }
        .input-wrap input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(11, 110, 138, .14);
        }
        .toggle {
            position: absolute; right: 8px; top: 50%;
            transform: translateY(-50%);
            border: none; background: none; cursor: pointer;
            color: var(--muted);
            padding: 8px; border-radius: 8px;
            display: flex;
        }
        .toggle:hover { color: var(--primary); background: var(--primary-light); }

        .btn {
            width: 100%;
            height: 48px;
            margin-top: 6px;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #fff;
            font-size: 15.5px;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            transition: transform .1s, box-shadow .2s;
        }
        .btn:hover { box-shadow: 0 8px 20px rgba(11, 110, 138, .3); }
        .btn:active { transform: translateY(1px); }
        .btn:focus-visible { outline: 3px solid rgba(20, 184, 166, .5); outline-offset: 2px; }

        .secure {
            margin-top: 24px;
            display: flex; align-items: center; justify-content: center; gap: 8px;
            font-size: 12.5px; color: var(--muted);
        }

        /* ---------- Responsive ---------- */
        @media (max-width: 800px) {
            .card { flex-direction: column; max-width: 480px; }
            .brand { padding: 28px 28px 24px; }
            .brand h2, .brand p.lead, .features, .brand footer { display: none; }
            .panel { padding: 32px 28px 36px; }
        }
    </style>
</head>
<body>

<main class="card">

    <!-- Brand side -->
    <aside class="brand">
        <div class="logo">
            <div class="logo-icon">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round">
                    <path d="M12 5v14M5 12h14"/>
                </svg>
            </div>
            <div class="logo-text">Clinic<span>Manager</span></div>
        </div>

        <div>
            <h2>Gérez votre clinique avec simplicité et sécurité.</h2>
            <p class="lead">Patients, rendez-vous et dossiers médicaux réunis dans une seule plateforme.</p>
            <ul class="features">
                <li><span class="dot"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#5eead4" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12l5 5L20 7"/></svg></span>Planning des rendez-vous</li>
                <li><span class="dot"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#5eead4" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12l5 5L20 7"/></svg></span>Dossiers patients centralisés</li>
                <li><span class="dot"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#5eead4" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12l5 5L20 7"/></svg></span>Données protégées et confidentielles</li>
            </ul>
        </div>

        <footer>&copy; 2026 ClinicManager. Tous droits réservés.</footer>
    </aside>

    <!-- Form side -->
    <section class="panel">
        <h1>Connexion</h1>
        <p class="subtitle">Accédez à votre espace professionnel.</p>

        <% if (request.getAttribute("error") != null) { %>
        <div class="alert" role="alert">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/>
            </svg>
            <span><%= esc(request.getAttribute("error")) %></span>
        </div>
        <% } %>

        <form method="post" action="${pageContext.request.contextPath}/login">
            <div class="field">
                <label for="email">Adresse e-mail</label>
                <div class="input-wrap">
                    <span class="icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/>
                        </svg>
                    </span>
                    <input type="email" id="email" name="email" required autocomplete="email"
                           placeholder="nom@clinique.com"
                           value="<%= esc(request.getAttribute("email")) %>">
                </div>
            </div>

            <div class="field">
                <label for="password">Mot de passe</label>
                <div class="input-wrap">
                    <span class="icon">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 018 0v4"/>
                        </svg>
                    </span>
                    <input type="password" id="password" name="password" required
                           autocomplete="current-password" placeholder="••••••••">
                    <button type="button" class="toggle" id="togglePwd" aria-label="Afficher le mot de passe">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z"/><circle cx="12" cy="12" r="3"/>
                        </svg>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn">Se connecter</button>
        </form>

        <div class="secure">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 2l8 3v6c0 5-3.5 9-8 11-4.5-2-8-6-8-11V5l8-3z"/>
            </svg>
            Connexion sécurisée
        </div>
    </section>
</main>

<script>
    (function () {
        var btn = document.getElementById('togglePwd');
        var input = document.getElementById('password');
        btn.addEventListener('click', function () {
            var show = input.type === 'password';
            input.type = show ? 'text' : 'password';
            btn.setAttribute('aria-label', show ? 'Masquer le mot de passe' : 'Afficher le mot de passe');
        });
    })();
</script>
</body>
</html>

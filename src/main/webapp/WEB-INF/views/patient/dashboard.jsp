<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.clinicmanager.model.Patient" %>
<%@ include file="/WEB-INF/views/patient/_layout.jspf" %>
<%
    Patient patient = (Patient) request.getAttribute("patient");
    request.setAttribute("activePage", "dashboard");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mon espace – ClinicManager</title>
    <link rel="stylesheet" href="<%= ctx %>/css/patient.css">
</head>
<body>
<%@ include file="/WEB-INF/views/patient/_sidebar.jspf" %>

<main class="main">
    <div class="topbar">
        <div>
            <h1>Bonjour, <%= esc(patient.getPrenom()) %> 👋</h1>
            <p>Bienvenue dans votre espace patient.</p>
        </div>
        <div class="user-chip">
            <div class="avatar"><%= esc(initials(patient.getNom() + " " + patient.getPrenom())) %></div>
            <div>
                <small>Connecté en tant que</small>
                <strong><%= esc(current.email()) %></strong>
            </div>
        </div>
    </div>

    <section class="panel">
        <div class="panel-head">
            <h2>Résumé de votre dossier</h2>
            <a class="btn btn-ghost" href="<%= ctx %>/patient/profile">Voir le profil complet</a>
        </div>
        <div class="panel-body">
            <div class="info-grid">
                <div class="info-item">
                    <div class="lbl">CIN</div>
                    <div class="val"><%= esc(patient.getCin()) %></div>
                </div>
                <div class="info-item">
                    <div class="lbl">Groupe sanguin</div>
                    <div class="val"><%= patient.getGroupeSanguin() != null ? esc(patient.getGroupeSanguin().getLabel()) : "—" %></div>
                </div>
                <div class="info-item">
                    <div class="lbl">Téléphone</div>
                    <div class="val"><%= esc(patient.getTelephone()) %></div>
                </div>
                <div class="info-item">
                    <div class="lbl">Adresse</div>
                    <div class="val"><%= esc(patient.getAdresse()) %></div>
                </div>
            </div>
        </div>
    </section>

    <section class="panel">
        <div class="panel-head">
            <h2>Accès rapides</h2>
        </div>
        <div class="panel-body" style="display:flex;gap:12px;flex-wrap:wrap">
            <a class="btn btn-primary" href="<%= ctx %>/patient/edit">✏️ Modifier mes informations</a>
            <a class="btn btn-ghost" href="<%= ctx %>/patient/appointments">📅 Mes rendez-vous</a>
            <a class="btn btn-ghost" href="<%= ctx %>/patient/history">📋 Historique médical</a>
        </div>
    </section>
</main>
</body>
</html>